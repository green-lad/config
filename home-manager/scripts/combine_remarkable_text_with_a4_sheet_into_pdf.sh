#!/bin/sh

pdfjam --outfile tmp.pdf --paper a4paper "A$1.pdf"
pdfunite "deckblatt_bei_einzelabgabe_annotated.pdf" tmp.pdf "C3_ad11ezol_A$1.pdf"
rm tmp.pdf
