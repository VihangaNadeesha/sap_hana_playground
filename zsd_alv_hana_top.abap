*&---------------------------------------------------------------------*
*& Include          ZSD_ALV_HANA_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TABLES: vbak, vbap.

CONSTANTS: c_repid TYPE sy-repid VALUE 'ZSD_ALV_HANA_REPORT'.

TYPES: BEGIN OF ty_output,
         vbeln       TYPE vbak-vbeln,
         auart       TYPE vbak-auart,
         audat       TYPE vbak-audat,
         ernam       TYPE vbak-ernam,
         kunnr       TYPE vbak-kunnr,
         name1       TYPE kna1-name1,
         posnr       TYPE vbap-posnr,
         matnr       TYPE vbap-matnr,
         maktx       TYPE makt-maktx,
         werks       TYPE vbap-werks,
         plant_name  TYPE t001w-name1,
         kwmeng      TYPE vbap-kwmeng,
         vrkme       TYPE vbap-vrkme,
         netwr       TYPE vbap-netwr,
         waerk       TYPE vbak-waerk,
       END OF ty_output.

DATA: gt_output    TYPE STANDARD TABLE OF ty_output,
      gs_layout    TYPE slis_layout_alv,
      gt_fieldcat  TYPE slis_t_fieldcat_alv,
      gs_fieldcat  TYPE slis_fieldcat_alv.
