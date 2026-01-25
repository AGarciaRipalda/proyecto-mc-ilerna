#!/usr/bin/env python3
"""
Script simple para convertir HTML a PDF usando Playwright
"""

import asyncio
from pathlib import Path

async def convert_html_to_pdf():
    try:
        from playwright.async_api import async_playwright
        
        html_file = Path("DOCUMENTACION_COMPLETA.html").absolute()
        pdf_file = Path("DOCUMENTACION_COMPLETA.pdf").absolute()
        
        print(f"📄 Convirtiendo {html_file.name} a PDF...")
        
        async with async_playwright() as p:
            browser = await p.chromium.launch()
            page = await browser.new_page()
            
            # Cargar el HTML
            await page.goto(f"file:///{html_file.as_posix()}")
            
            # Esperar a que se cargue completamente
            await page.wait_for_load_state('networkidle')
            
            # Generar PDF con configuración profesional
            await page.pdf(
                path=str(pdf_file),
                format='A4',
                margin={
                    'top': '20mm',
                    'right': '20mm',
                    'bottom': '20mm',
                    'left': '20mm'
                },
                print_background=True,
                display_header_footer=True,
                header_template='<div style="font-size:10px; text-align:center; width:100%;">Documentación Completa - Proyecto Mc Ilerna</div>',
                footer_template='<div style="font-size:10px; text-align:center; width:100%;"><span class="pageNumber"></span> / <span class="totalPages"></span></div>'
            )
            
            await browser.close()
            
        print(f"✅ PDF generado exitosamente: {pdf_file.name}")
        print(f"📊 Tamaño: {pdf_file.stat().st_size:,} bytes")
        return True
        
    except ImportError:
        print("❌ Playwright no está instalado")
        print("💡 Instalar con: pip install playwright && playwright install chromium")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    asyncio.run(convert_html_to_pdf())
