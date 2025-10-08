#!/usr/bin/env python3
import argparse
import base64
import json
import os
import sys
import xml.etree.ElementTree as ET


NS = {
    'pbds': 'http://pacificbiosciences.com/PacBioDatasets.xsd',
    'pbbase': 'http://pacificbiosciences.com/PacBioBaseDataModel.xsd',
    'pbmeta': 'http://pacificbiosciences.com/PacBioCollectionMetadata.xsd',
    'pbsample': 'http://pacificbiosciences.com/PacBioSampleInfo.xsd',
}


def text(elem):
    return elem.text.strip() if elem is not None and elem.text else None


def decode_b64(s):
    try:
        return base64.b64decode(s).decode()
    except Exception:
        return None


def parse_dataset_xml(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Top-level attributes
    ds_meta = {
        'Name': root.attrib.get('Name'),
        'MetaType': root.attrib.get('MetaType'),
        'CreatedAt': root.attrib.get('CreatedAt'),
        'Version': root.attrib.get('Version'),
        'UniqueId': root.attrib.get('UniqueId'),
        'Tags': root.attrib.get('Tags'),
    }

    # External resources (segmented BAM)
    ext_resources = []
    for er in root.findall('.//pbbase:ExternalResources/pbbase:ExternalResource', NS):
        ext_resources.append({
            'MetaType': er.attrib.get('MetaType'),
            'ResourceId': er.attrib.get('ResourceId'),
        })

    # Supplemental resources (summary CSV/JSON)
    supp_resources = []
    for er in root.findall('.//pbbase:SupplementalResources/pbbase:ExternalResource', NS):
        supp_resources.append({
            'MetaType': er.attrib.get('MetaType'),
            'ResourceId': er.attrib.get('ResourceId'),
        })

    # Adapter/primer sequences
    left_adapter = text(root.find('.//pbmeta:LeftAdaptorSequence', NS))
    right_adapter = text(root.find('.//pbmeta:RightAdaptorSequence', NS))
    right_primer = text(root.find('.//pbmeta:RightPrimerSequence', NS))
    custom_seq = text(root.find('.//pbmeta:CustomSequence', NS))

    # Barcodes FASTA (base64)
    barcodes_b64 = text(root.find('.//pbmeta:BarcodesFasta', NS))
    barcodes_fasta = decode_b64(barcodes_b64) if barcodes_b64 else None

    # DNABarcodes listed under samples
    sample_barcodes = []
    for bc in root.findall('.//pbsample:DNABarcode', NS):
        nm = bc.attrib.get('Name')
        if nm:
            sample_barcodes.append(nm)

    return {
        'dataset': ds_meta,
        'external_resources': ext_resources,
        'supplemental_resources': supp_resources,
        'adapters_primers': {
            'LeftAdaptorSequence': left_adapter,
            'RightAdaptorSequence': right_adapter,
            'RightPrimerSequence': right_primer,
            'CustomSequence_len': len(custom_seq) if custom_seq else None,
        },
        'barcodes': {
            'DNABarcodes_in_metadata': sorted(set(sample_barcodes)),
            'BarcodesFasta_raw_b64_len': len(barcodes_b64) if barcodes_b64 else 0,
            'BarcodesFasta_decoded_preview': '\n'.join((barcodes_fasta or '').splitlines()[:20]) if barcodes_fasta else None,
        },
    }


def write_outputs(xml_path, summary, write_decoded_barcodes=False):
    out_json = os.path.splitext(xml_path)[0] + '.summary.json'
    out_txt = os.path.splitext(xml_path)[0] + '.summary.txt'
    with open(out_json, 'w') as f:
        json.dump(summary, f, indent=2)

    # Human-readable text
    lines = []
    ds = summary['dataset']
    lines.append(f"Name: {ds.get('Name')}")
    lines.append(f"MetaType: {ds.get('MetaType')}  Version: {ds.get('Version')}  CreatedAt: {ds.get('CreatedAt')}")
    lines.append(f"UniqueId: {ds.get('UniqueId')}  Tags: {ds.get('Tags')}")
    lines.append('')
    lines.append('External resources:')
    for er in summary['external_resources']:
        lines.append(f"  - {er['MetaType']}: {er['ResourceId']}")
    lines.append('')
    lines.append('Supplemental resources:')
    for er in summary['supplemental_resources']:
        lines.append(f"  - {er['MetaType']}: {er['ResourceId']}")
    lines.append('')
    ap = summary['adapters_primers']
    lines.append('Adapters/Primers:')
    lines.append(f"  LeftAdaptorSequence:  {ap.get('LeftAdaptorSequence')}")
    lines.append(f"  RightAdaptorSequence: {ap.get('RightAdaptorSequence')}")
    lines.append(f"  RightPrimerSequence:  {ap.get('RightPrimerSequence')}")
    lines.append(f"  CustomSequence_len:   {ap.get('CustomSequence_len')}")
    lines.append('')
    bc = summary['barcodes']
    lines.append('Barcodes (from metadata):')
    for nm in bc['DNABarcodes_in_metadata']:
        lines.append(f"  - {nm}")
    if bc.get('BarcodesFasta_decoded_preview'):
        lines.append('')
        lines.append('BarcodesFasta (decoded preview):')
        lines.append(bc['BarcodesFasta_decoded_preview'])

    with open(out_txt, 'w') as f:
        f.write('\n'.join(lines) + '\n')

    # Optionally write full decoded barcodes FASTA
    if write_decoded_barcodes and summary['barcodes'].get('BarcodesFasta_decoded_preview'):
        # We only stored preview in summary to keep memory light; re-decode fully here
        tree = ET.parse(xml_path)
        root = tree.getroot()
        barcodes_b64 = text(root.find('.//pbmeta:BarcodesFasta', NS))
        barcodes_fasta = decode_b64(barcodes_b64) if barcodes_b64 else None
        if barcodes_fasta:
            out_fa = os.path.splitext(xml_path)[0] + '.barcodes.fasta'
            with open(out_fa, 'w') as f:
                f.write(barcodes_fasta)


def main():
    ap = argparse.ArgumentParser(description='Summarize PacBio ConsensusReadSet XML (skera split outputs).')
    ap.add_argument('xml', help='Path to segmented.consensusreadset.xml')
    ap.add_argument('--write-barcodes-fasta', action='store_true', help='Also write decoded barcodes FASTA next to XML')
    args = ap.parse_args()

    summary = parse_dataset_xml(args.xml)
    write_outputs(args.xml, summary, write_decoded_barcodes=args.write_barcodes_fasta)
    print('Wrote:', os.path.splitext(args.xml)[0] + '.summary.json')
    print('Wrote:', os.path.splitext(args.xml)[0] + '.summary.txt')
    if args.write_barcodes_fasta:
        print('Wrote:', os.path.splitext(args.xml)[0] + '.barcodes.fasta')


if __name__ == '__main__':
    sys.exit(main())
