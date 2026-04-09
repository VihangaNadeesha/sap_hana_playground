*&---------------------------------------------------------------------*
*& Include          ZSD_ALV_HANA_F01
*&---------------------------------------------------------------------*
FORM validate_selection.
  IF s_vbeln[] IS INITIAL
     AND s_audat[] IS INITIAL
     AND s_kunnr[] IS INITIAL
     AND s_auart[] IS INITIAL
     AND s_werks[] IS INITIAL.
    MESSAGE 'Provide at least one selection criterion.' TYPE 'E'.
  ENDIF.
ENDFORM.

FORM get_data.
  CLEAR gt_output.

  " HANA-friendly approach:
  " - Single set-based SELECT with explicit field list
  " - Restrictive WHERE from selection screen
  " - Language-dependent text join (MAKT) using SY-LANGU
  SELECT
    vbak~vbeln,
    vbak~auart,
    vbak~audat,
    vbak~ernam,
    vbak~kunnr,
    kna1~name1,
    vbap~posnr,
    vbap~matnr,
    makt~maktx,
    vbap~werks,
    t001w~name1 AS plant_name,
    vbap~kwmeng,
    vbap~vrkme,
    vbap~netwr,
    vbak~waerk
    FROM vbak
    INNER JOIN vbap
      ON vbap~vbeln = vbak~vbeln
    INNER JOIN kna1
      ON kna1~kunnr = vbak~kunnr
    LEFT OUTER JOIN makt
      ON makt~matnr = vbap~matnr
     AND makt~spras = @sy-langu
    LEFT OUTER JOIN t001w
      ON t001w~werks = vbap~werks
    WHERE vbak~vbeln IN @s_vbeln
      AND vbak~audat IN @s_audat
      AND vbak~kunnr IN @s_kunnr
      AND vbak~auart IN @s_auart
      AND vbap~werks IN @s_werks
    INTO TABLE @gt_output.

  IF sy-subrc <> 0 OR gt_output IS INITIAL.
    MESSAGE 'No data found for the selection criteria.' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SORT gt_output BY vbeln posnr.
ENDFORM.

FORM build_fieldcatalog.
  CLEAR gt_fieldcat.

  PERFORM append_fieldcat USING 'VBELN'      'Sales Order'      10.
  PERFORM append_fieldcat USING 'AUART'      'Order Type'       6.
  PERFORM append_fieldcat USING 'AUDAT'      'Doc Date'         10.
  PERFORM append_fieldcat USING 'ERNAM'      'Created By'       12.
  PERFORM append_fieldcat USING 'KUNNR'      'Customer'         10.
  PERFORM append_fieldcat USING 'NAME1'      'Customer Name'    25.
  PERFORM append_fieldcat USING 'POSNR'      'Item'             6.
  PERFORM append_fieldcat USING 'MATNR'      'Material'         18.
  PERFORM append_fieldcat USING 'MAKTX'      'Material Desc.'   30.
  PERFORM append_fieldcat USING 'WERKS'      'Plant'            4.
  PERFORM append_fieldcat USING 'PLANT_NAME' 'Plant Name'       20.
  PERFORM append_fieldcat USING 'KWMENG'     'Order Qty'        13.
  PERFORM append_fieldcat USING 'VRKME'      'UoM'              5.
  PERFORM append_fieldcat USING 'NETWR'      'Net Value'        15.
  PERFORM append_fieldcat USING 'WAERK'      'Currency'         5.
ENDFORM.

FORM append_fieldcat USING p_field
                           p_text
                           p_len.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = p_field.
  gs_fieldcat-seltext_l  = p_text.
  gs_fieldcat-outputlen  = p_len.
  APPEND gs_fieldcat TO gt_fieldcat.
ENDFORM.

FORM display_alv.
  PERFORM build_fieldcatalog.

  CLEAR gs_layout.
  gs_layout-colwidth_optimize = abap_true.
  gs_layout-zebra             = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = c_repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
    TABLES
      t_outtab           = gt_output
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE 'ALV display failed.' TYPE 'E'.
  ENDIF.
ENDFORM.
