import os
import markdown
from xhtml2pdf import pisa

HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
@page {
    size: a4;
    margin: 2.5cm 2cm 2.5cm 2cm;
    @frame footer {
        -pdf-frame-content: footerContent;
        bottom: 1.5cm;
        margin-left: 2cm;
        margin-right: 2cm;
        height: 1cm;
    }
}
body {
    font-family: Helvetica, Arial, sans-serif;
    color: #1e293b;
    font-size: 10pt;
    line-height: 1.6;
}
h1 {
    font-size: 22pt;
    color: #1e3a8a;
    border-bottom: 2px solid #3b82f6;
    padding-bottom: 8px;
    margin-top: 0;
    margin-bottom: 20px;
}
h2 {
    font-size: 15pt;
    color: #1e3a8a;
    margin-top: 25px;
    margin-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
    padding-bottom: 4px;
}
h3 {
    font-size: 12pt;
    color: #2563eb;
    margin-top: 18px;
    margin-bottom: 8px;
}
p {
    margin-bottom: 12px;
    text-align: justify;
}
ul, ol {
    margin-bottom: 12px;
    padding-left: 20px;
}
li {
    margin-bottom: 6px;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    margin-bottom: 20px;
}
th {
    background-color: #3b82f6;
    color: white;
    font-weight: bold;
    text-align: left;
    padding: 6px 10px;
    border: 1px solid #cbd5e1;
}
td {
    padding: 6px 10px;
    border: 1px solid #cbd5e1;
}
tr:nth-child(even) {
    background-color: #f8fafc;
}
code {
    font-family: monospace;
    background-color: #f1f5f9;
    padding: 1px 3px;
    font-size: 9pt;
}
pre {
    font-family: monospace;
    background-color: #f1f5f9;
    padding: 8px;
    border: 1px solid #cbd5e1;
    margin-bottom: 12px;
}
blockquote {
    border-left: 4px solid #3b82f6;
    background-color: #f0f7ff;
    padding: 8px 12px;
    margin-left: 0;
    margin-right: 0;
    margin-bottom: 12px;
}
.page-break {
    page-break-after: always;
}
</style>
</head>
<body>
    <div id="content">
        {content}
    </div>
    
    <div id="footerContent" style="text-align: center; color: #64748b; font-size: 8pt; border-top: 1px solid #e2e8f0; padding-top: 5px;">
        ZekDrive - Document Projet | Page <pdf:pagenumber> sur <pdf:pagecount>
    </div>
</body>
</html>
"""

def md_to_pdf(md_path, pdf_path):
    print(f"Conversion de {md_path} en {pdf_path}...")
    with open(md_path, "r", encoding="utf-8") as f:
        md_text = f.read()
    
    # Convert md to html
    md_parser = markdown.Markdown(extensions=['tables', 'fenced_code'])
    html_body = md_parser.convert(md_text)
    
    # Replace markdown alerts like "> [!IMPORTANT]" with styled blockquotes
    html_body = html_body.replace('[!IMPORTANT]', '<strong>⚠️ IMPORTANT :</strong>')
    html_body = html_body.replace('[!NOTE]', '<strong>ℹ️ NOTE :</strong>')
    html_body = html_body.replace('[!TIP]', '<strong>💡 CONSEIL :</strong>')
    html_body = html_body.replace('[!WARNING]', '<strong>⚠️ ATTENTION :</strong>')
    html_body = html_body.replace('[!CAUTION]', '<strong>🛑 DANGER :</strong>')
    
    # Wrap in template
    full_html = HTML_TEMPLATE.replace("{content}", html_body)
    
    # Generate PDF
    with open(pdf_path, "wb") as f_pdf:
        pisa_status = pisa.CreatePDF(full_html, dest=f_pdf)
        
    if pisa_status.err:
        print(f"Erreur de conversion pour {md_path}")
    else:
        print(f"Conversion réussie : {pdf_path}")

def main():
    dir_path = os.path.dirname(os.path.realpath(__file__))
    for file in os.listdir(dir_path):
        if file.endswith(".md"):
            md_file = os.path.join(dir_path, file)
            pdf_file = os.path.join(dir_path, file.replace(".md", ".pdf"))
            md_to_pdf(md_file, pdf_file)

if __name__ == "__main__":
    main()
