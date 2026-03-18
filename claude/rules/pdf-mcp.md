---
paths:
  - "**/*.pdf"
---

# PDF MCP Tool Selection

Two PDF MCP servers are available. Follow this decision tree:

## Primary: pdf-mcp (fast, cached)
Use for the FIRST attempt on any PDF task. Lightweight PyMuPDF-based extraction with SQLite caching.
- Always start with `pdf_info` to check document structure
- Then use `pdf_search` or `pdf_read_pages` as needed
- Suitable for: digital PDFs, text extraction, keyword search, metadata retrieval

## Fallback: pdf-docling (rich, OCR-capable)
Switch to pdf-docling when pdf-mcp produces poor results OR when advanced features are needed:
- **OCR required**: pdf-mcp returns empty/garbled text (likely a scanned PDF)
- **Table structure needed**: user asks for structured table data extraction
- **Document editing/creation**: adding sections, paragraphs, tables to a document
- **Multi-format input**: source is DOCX, PPTX, XLSX, HTML, or image (not PDF)
- **Markdown export**: user wants clean Markdown output of the full document
- **Layout analysis**: understanding document structure (headings, sections, hierarchy)

## Decision flow
1. Start with `pdf-mcp.pdf_info` to assess the document
2. If text extraction works well -> continue with pdf-mcp
3. If text is empty/garbled, or tables/OCR/editing needed -> switch to pdf-docling
