import json

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH


import re
import io
import sys
import shutil

if len(sys.argv) > 1:
    data = json.load(open(sys.argv[1])) # '/home/martin/Projects/word-py/ex.json'))
else:
    data = json.load(sys.stdin)
    with open('/tmp/dump.js', 'w') as out:
        json.dump(data, out) # debug dump

    #data = json.load(open('/home/martin/Projects/word-py/ex.json'))

document = Document()
#p = document.add_paragraph(json.dumps(data)) # debug dump

# set styles
styles = document.styles
styles['Heading 1'].font.color.rgb = RGBColor(0xBF, 0x00, 0x41)
styles['Heading 1'].font.underline = False
styles['Heading 1'].font.size = Pt(28)

styles['Heading 2'].font.underline = True
styles['Heading 2'].font.color.rgb = RGBColor(0x00, 0x00, 0x00)
styles['Heading 2'].font.size = Pt(16)

styles['Heading 3'].font.underline = False
styles['Heading 3'].font.color.rgb = RGBColor(0x00, 0x00, 0x00)
styles['Heading 3'].paragraph_format.alignment = WD_ALIGN_PARAGRAPH.CENTER
styles['Heading 3'].font.size = Pt(14)

same_heslo = ''
same_meaning = ''
same_urceni = ''

def format_urceni(u):
    if u == None or u["pad"] == None:
        return ""

    md = re.match("(\d)(\w)", u["pad"])
    if not md:
        return ""

    num_str = "sg." if md.groups()[1] == "s" else "pl."

    urceni_string = f'{md.groups()[0]} {num_str}'

    if u["rod"] != None and u["rod"] != " ":
        urceni_string = f'{urceni_string} {u["rod"]}'

    return urceni_string

for e in data:
    if same_heslo != e['heslo']:
        heslo_text = f'{e["heslo"]} {e["entry_full"]["rod"]}.'
        document.add_heading(heslo_text, 1)
        same_heslo = e['heslo']
        same_meaning = ''
        same_urceni = ''

    if same_meaning != e['vyznam']:
        #document.add_heading(vyznam_text, 2)

        p = document.add_paragraph(f'{e["vyznam_full"]["cislo"]}. ', style='Heading 2')
        if None != e["vyznam_full"]["kvalifikator"]:
            p.add_run(e["vyznam_full"]["kvalifikator"]).bold = False
        p.add_run(e["vyznam"])

        same_meaning = e['vyznam']
        same_urceni = ''

    if same_urceni != e['urceni_sort']:
        urceni_string = format_urceni(e['urceni_full'][0])
        document.add_heading(urceni_string, 3)
        same_urceni = e['urceni_sort']

    p = document.add_paragraph('', style='List Bullet')
    # splitnout exemplifikaci podle vyrazu, vyrazy tucne
    parts = re.split("(\{.*?\})", e['exemplifikace'])
    for part in parts:
        if part.startswith('{'):
            p.add_run(part).bold = True
        else:
            p.add_run(part).italic = True

    p.add_run('; ')
    
    # lokalizace cervene
    if 'lokalizace_format' in e and e['lokalizace_format'] != '':
        run = p.add_run(e['lokalizace_format'])
        font = run.font
        font.size = Pt(10)
        font.color.rgb = RGBColor(0xE9, 0x24, 0x42)
        p.add_run('; ')

    # zdroj modre
    if 'zdroj_name' in e:
        run = p.add_run(e['zdroj_name'])
        font = run.font
        font.size = Pt(12)
        font.color.rgb = RGBColor(0x42, 0x24, 0xE9)

# document.add_heading('Document Title', 0)

# p = document.add_paragraph('A plain paragraph having some ')
# p.add_run('bold').bold = True
# p.add_run(' and some ')
# p.add_run('italic.').italic = True
# 
# document.add_heading('Heading, level 1', level=1)
# document.add_paragraph('Intense quote', style='Intense Quote')
# 
# document.add_paragraph(
#     'first item in unordered list', style='List Bullet'
# )
# document.add_paragraph(
#     'first item in ordered list', style='List Number'
# )
# 
# document.add_picture('monty-truth.png', width=Inches(1.25))
# 
# records = (
#     (3, '101', 'Spam'),
#     (7, '422', 'Eggs'),
#     (4, '631', 'Spam, spam, eggs, and spam')
# )
# 
# table = document.add_table(rows=1, cols=3)
# hdr_cells = table.rows[0].cells
# hdr_cells[0].text = 'Qty'
# hdr_cells[1].text = 'Id'
# hdr_cells[2].text = 'Desc'
# for qty, id, desc in records:
#     row_cells = table.add_row().cells
#     row_cells[0].text = str(qty)
#     row_cells[1].text = id
#     row_cells[2].text = desc
# 
# document.add_page_break()


target_stream = io.BytesIO()
document.save(target_stream)
target_stream.seek(0)
sys.stdout.buffer.write(target_stream.read())
