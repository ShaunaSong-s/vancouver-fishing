"""PDF invoice generator for fishing charter trips."""

from pathlib import Path

from fpdf import FPDF

from app.models.invoice import Invoice

PDF_OUTPUT_DIR = Path(__file__).parent.parent.parent / "data" / "invoices"


class InvoicePDF(FPDF):
    def header(self):
        logo_path = Path(__file__).parent.parent / "static" / "logo.png"
        if logo_path.exists():
            self.image(str(logo_path), x=10, y=8, w=20)
        self.set_font("Helvetica", "B", 18)
        self.cell(0, 10, "Top Vancouver Fishing Charter Inc.", align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("Helvetica", "", 9)
        self.cell(0, 5, "Georgia Strait | Steveston, BC, Canada", align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(5)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(5)

    def footer(self):
        self.set_y(-25)
        self.set_font("Helvetica", "I", 8)
        self.cell(0, 4, "Thank you for choosing Top Vancouver Fishing Charter Inc.!", align="C", new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 4, "Payment: E-Transfer to info@topfishingcharter.ca", align="C", new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 4, f"Page {self.page_no()}/{{nb}}", align="C")


def generate_invoice_pdf(invoice: Invoice) -> str:
    """Generate a PDF for the given invoice. Returns the file path."""
    PDF_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    pdf = InvoicePDF()
    pdf.alias_nb_pages()
    pdf.add_page()
    pdf.set_auto_page_break(auto=True, margin=30)

    # Invoice header info
    pdf.set_font("Helvetica", "B", 14)
    pdf.cell(0, 8, f"INVOICE  {invoice.invoice_number}", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)

    pdf.set_font("Helvetica", "", 10)
    pdf.cell(95, 5, f"Date: {invoice.date}", new_x="RIGHT")
    pdf.cell(95, 5, f"Status: {invoice.status.value.upper()}", align="R", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(5)

    # Customer info
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 6, "Bill To:", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    pdf.cell(0, 5, f"  {invoice.customer.name}", new_x="LMARGIN", new_y="NEXT")
    if invoice.customer.email:
        pdf.cell(0, 5, f"  {invoice.customer.email}", new_x="LMARGIN", new_y="NEXT")
    if invoice.customer.phone:
        pdf.cell(0, 5, f"  {invoice.customer.phone}", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(10)

    # Description and amount
    pdf.set_font("Helvetica", "B", 10)
    pdf.set_fill_color(230, 240, 250)
    pdf.cell(130, 7, "Description", border=1, fill=True)
    pdf.cell(60, 7, "Amount", border=1, align="C", fill=True, new_x="LMARGIN", new_y="NEXT")

    pdf.set_font("Helvetica", "", 10)
    pdf.cell(130, 7, invoice.description, border=1)
    pdf.cell(60, 7, f"${invoice.amount:.2f}", border=1, align="R", new_x="LMARGIN", new_y="NEXT")

    pdf.ln(5)

    # Totals
    x_label = 125
    w_label = 40
    w_val = 35

    pdf.set_font("Helvetica", "", 10)
    pdf.set_x(x_label)
    pdf.cell(w_label, 6, "Subtotal:", align="R")
    pdf.cell(w_val, 6, f"${invoice.amount:.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    pdf.set_x(x_label)
    pdf.cell(w_label, 6, f"GST ({invoice.tax_rate*100:.0f}%):", align="R")
    pdf.cell(w_val, 6, f"${invoice.tax_amount:.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    pdf.set_font("Helvetica", "B", 12)
    pdf.set_x(x_label)
    pdf.cell(w_label, 8, "TOTAL:", align="R")
    pdf.cell(w_val, 8, f"${invoice.total:.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    # Notes
    if invoice.notes:
        pdf.ln(10)
        pdf.set_font("Helvetica", "B", 10)
        pdf.cell(0, 5, "Notes:", new_x="LMARGIN", new_y="NEXT")
        pdf.set_font("Helvetica", "", 9)
        pdf.multi_cell(0, 5, invoice.notes)

    # Save
    filename = f"{invoice.invoice_number}.pdf"
    filepath = PDF_OUTPUT_DIR / filename
    pdf.output(str(filepath))

    return str(filepath)
