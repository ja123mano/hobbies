"""Print HTML report."""
import csv
import os
from jinja2 import Environment, FileSystemLoader

def print_html_doc(dictionary_data):
    """Generate the html index."""
    THIS_DIR = os.path.dirname(os.path.abspath(__file__))
    j2_env = Environment(loader=FileSystemLoader(THIS_DIR),
                         trim_blocks=True)
    print(j2_env.get_template('test_template.html').
          render(data=dictionary_data),
          file=open("index.html", "w"))

def main():

    outfile = 'output.csv'
    data = {}

    with open(outfile, mode='r') as infile:
        reader = csv.reader(infile)
        for rows in reader:
            pkg = rows[0]
            status = rows[1]
            author = rows[2]
            if author != 'N/A':
                if os.path.isfile('logs/%s-build.log' % (pkg)):
                    logfile = './logs/%s-build.log' % (pkg)
                else:
                    logfile = 'N/A'
                data[pkg] = {'autospec_status':status, 'last_commit':author,'logfile':logfile}

    print_html_doc(data)
    print(data)

if __name__ == '__main__':
    main()
