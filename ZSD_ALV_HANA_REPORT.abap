*&---------------------------------------------------------------------*
*& Report  ZSD_ALV_HANA_REPORT
*&---------------------------------------------------------------------*
*& Purpose:
*&   SD analytical ALV report (HANA-friendly Open SQL) using
*&   conventional ABAP with INCLUDEs and PERFORM routines.
*&
*& Main scenario:
*&   Sales order item overview with customer, material and plant context.
*&
*& Joins used:
*&   VBAK + VBAP + KNA1 + MAKT + T001W (5 tables).
*&---------------------------------------------------------------------*
REPORT zsd_alv_hana_report.

INCLUDE zsd_alv_hana_top.
INCLUDE zsd_alv_hana_sel.
INCLUDE zsd_alv_hana_f01.

START-OF-SELECTION.
  PERFORM validate_selection.
  PERFORM get_data.

END-OF-SELECTION.
  PERFORM display_alv.
