*&---------------------------------------------------------------------*
*& Include          ZSD_ALV_HANA_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS:
  s_vbeln FOR vbak-vbeln,
  s_audat FOR vbak-audat,
  s_kunnr FOR vbak-kunnr,
  s_auart FOR vbak-auart,
  s_werks FOR vbap-werks.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  text-t01 = 'SD Order Item Analysis'.
