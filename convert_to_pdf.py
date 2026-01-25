#!/usr/bin/env python3
"""
Script para convertir el documento Markdown a PDF
usando markdown-pdf o alternativas
"""

import subprocess
import sys
import os

def convert_with_weasyprint():
    """Intenta convertir usando WeasyPrint (HTML -> PDF)"""
    try:
        import weasyprint
        from markdown import markdown
        
        # Leer el archivo Markdown
        with open('DOCUMENTACION_COMPLETA.md', 'r', encoding='utf-8') as f:
            md_content = f.read()
        
        # Convertir Markdown a HTML
        html_content = markdown(md_content, extensions=['tables', 'fenced_code', 'toc'])
        
        # Crear HTML completo con estilos
        full_html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    line-height: 1.6;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    color: #333;
                }}
                h1 {{
                    color: #d32f2f;
                    border-bottom: 3px solid #d32f2f;
                    padding-bottom: 10px;
                }}
                h2 {{
                    color: #d32f2f;
                    border-bottom: 2px solid #f44336;
                    padding-bottom: 5px;
                    margin-top: 30px;
                }}
                h3 {{
                    color: #e53935;
                    margin-top: 20px;
                }}
                table {{
                    border-collapse: collapse;
                    width: 100%;
                    margin: 20px 0;
                }}
                th, td {{
                    border: 1px solid #ddd;
                    padding: 12px;
                    text-align: left;
                }}
                th {{
                    background-color: #d32f2f;
                    color: white;
                }}
                tr:nth-child(even) {{
                    background-color: #f9f9f9;
                }}
                code {{
                    background-color: #f5f5f5;
                    padding: 2px 6px;
                    border-radius: 3px;
                    font-family: 'Courier New', monospace;
                }}
                pre {{
                    background-color: #f5f5f5;
                    padding: 15px;
                    border-radius: 5px;
                    overflow-x: auto;
                }}
                pre code {{
                    background-color: transparent;
                    padding: 0;
                }}
                blockquote {{
                    border-left: 4px solid #d32f2f;
                    padding-left: 20px;
                    margin-left: 0;
                    color: #666;
                }}
                @page {{
                    margin: 2cm;
                    @top-center {{
                        content: "Documentación Completa - Proyecto Mc Ilerna";
                    }}
                    @bottom-center {{
                        content: counter(page);
                    }}
                }}
            </style>
        </head>
        <body>
            {html_content}
        </body>
        </html>
        """
        
        # Generar PDF
        weasyprint.HTML(string=full_html).write_pdf('DOCUMENTACION_COMPLETA.pdf')
        print("✅ PDF generado exitosamente con WeasyPrint")
        return True
        
    except ImportError:
        print("❌ WeasyPrint no está instalado")
        return False
    except Exception as e:
        print(f"❌ Error con WeasyPrint: {e}")
        return False

def convert_with_pypandoc():
    """Intenta convertir usando pypandoc"""
    try:
        import pypandoc
        
        output = pypandoc.convert_file(
            'DOCUMENTACION_COMPLETA.md',
            'pdf',
            outputfile='DOCUMENTACION_COMPLETA.pdf',
            extra_args=[
                '--pdf-engine=wkhtmltopdf',
                '-V', 'geometry:margin=1in',
                '--toc',
                '--toc-depth=3'
            ]
        )
        print("✅ PDF generado exitosamente con pypandoc")
        return True
        
    except ImportError:
        print("❌ pypandoc no está instalado")
        return False
    except Exception as e:
        print(f"❌ Error con pypandoc: {e}")
        return False

def convert_with_pdfkit():
    """Intenta convertir usando pdfkit (wkhtmltopdf wrapper)"""
    try:
        import pdfkit
        from markdown import markdown
        
        # Leer el archivo Markdown
        with open('DOCUMENTACION_COMPLETA.md', 'r', encoding='utf-8') as f:
            md_content = f.read()
        
        # Convertir Markdown a HTML
        html_content = markdown(md_content, extensions=['tables', 'fenced_code', 'toc'])
        
        # Configuración de pdfkit
        options = {
            'page-size': 'A4',
            'margin-top': '0.75in',
            'margin-right': '0.75in',
            'margin-bottom': '0.75in',
            'margin-left': '0.75in',
            'encoding': 'UTF-8',
            'enable-local-file-access': None
        }
        
        pdfkit.from_string(html_content, 'DOCUMENTACION_COMPLETA.pdf', options=options)
        print("✅ PDF generado exitosamente con pdfkit")
        return True
        
    except ImportError:
        print("❌ pdfkit no está instalado")
        return False
    except Exception as e:
        print(f"❌ Error con pdfkit: {e}")
        return False

def main():
    print("🔄 Intentando convertir DOCUMENTACION_COMPLETA.md a PDF...\n")
    
    # Intentar diferentes métodos en orden de preferencia
    methods = [
        ("WeasyPrint", convert_with_weasyprint),
        ("pdfkit", convert_with_pdfkit),
        ("pypandoc", convert_with_pypandoc),
    ]
    
    for method_name, method_func in methods:
        print(f"\n📝 Intentando con {method_name}...")
        if method_func():
            print(f"\n✅ ¡Éxito! PDF generado con {method_name}")
            if os.path.exists('DOCUMENTACION_COMPLETA.pdf'):
                size = os.path.getsize('DOCUMENTACION_COMPLETA.pdf')
                print(f"📄 Tamaño del archivo: {size:,} bytes")
            return 0
    
    print("\n❌ No se pudo generar el PDF con ningún método")
    print("\n💡 Sugerencias:")
    print("   - Instalar WeasyPrint: pip install weasyprint markdown")
    print("   - Instalar pdfkit: pip install pdfkit markdown")
    print("   - Instalar pypandoc: pip install pypandoc")
    return 1

if __name__ == "__main__":
    sys.exit(main())
