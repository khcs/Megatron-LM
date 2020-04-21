import glob, os, argparse, json
import pubmed_parser as pmp

class PubMedTextFormatting:
    def __init__(self, pubmed_path, output_filename, recursive = False):
        self.pubmed_path = pubmed_path
        self.recursive = recursive
        self.output_filename = output_filename

    def write_dicts(self, dicts_out, dict_key, ofile, title_key, doc_type):
        for dict_out in dicts_out:
            data = {}

            if not dict_out[dict_key]:
                continue
            try:
                data['pmid'] = dict_out['pmid']
                # data['doi'] = dict_out['doi']
                data['title'] = dict_out[title_key]
                data['type'] = doc_type
                data['text'] = ""

                for line in dict_out[dict_key].splitlines():
                    if len(line) <  30:
                        continue
                    # ofile.write(line.strip() + " ")
                    data['text'] += (line.strip() + " ")
                # ofile.write("\n\n")
                data['text'] += "\n\n"
            except:
                # ofile.write("\n\n")
                continue
        
            if bool(data):
                json.dump(data, ofile)
                ofile.write("\n")

    # This puts one article per line
    def merge(self):
        print('PubMed path:', self.pubmed_path)
        
        with open(self.output_filename, mode='w', newline='\n') as ofile:
            
            # PubMed
            for filename in glob.glob(os.path.join(self.pubmed_path, '**/*.xml'), 
                                      recursive=self.recursive):
                print('file:', filename)
                dicts_out = pmp.parse_medline_xml(filename)

                self.write_dicts(dicts_out, 'abstract', ofile, 'title', 'pubmed_abstract')
                
            # PMC
            for filename in glob.glob(os.path.join(self.pubmed_path, '**/*.nxml'), 
                                        recursive=self.recursive):
                print('file:', filename)

                # OA abstract
                try:
                    dicts_out = [pmp.parse_pubmed_xml(filename)]
                    self.write_dicts(dicts_out, 'abstract', ofile, 'full_title', 'pmc_oa_abstract')
                except:
                    pass

                # OA image caption
                try:
                    dicts_out = pmp.parse_pubmed_caption(filename)
                    self.write_dicts(dicts_out, 'fig_caption', ofile, 'fig_label', 'pmc_oa_image-caption')
                except:
                    pass

                # OA Paragraph
                try:
                    dicts_out = pmp.parse_pubmed_paragraph(filename, all_paragraph=True)
                    self.write_dicts(dicts_out, 'text', ofile, 'reference_ids', 'pmc_oa_paragraph')
                except:
                    pass


def main(args):
    pubmed_formatter = PubMedTextFormatting(args.pubmed_data_dir,
                                            args.json_filename,
                                            recursive=True)
    pubmed_formatter.merge()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--pubmed_data_dir',
        type=str,
        help='Specify the dataset location',
        default=None
    )

    parser.add_argument(
        '--json_filename',
        type=str,
        help='Specify the output json filename',
        default=None
    )

    args = parser.parse_args()

    main(args)