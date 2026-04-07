*&---------------------------------------------------------------------*
*& Module Pool      ZCUSTOMER_MODULE_POOL
*&---------------------------------------------------------------------*
*& Purpose:
*&   Display customer master data (KNA1) on screen 0100 using
*&   Object-Oriented ABAP with clear separation of concerns.
*&
*& Screen 0100 elements (example names in Screen Painter):
*&   - Input  : KUNNR
*&   - Output : NAME1, CITY1, COUNTRY
*&   - Buttons: DISPLAY, CLEAR, EXIT
*&
*& Suggested GUI status for screen 0100:
*&   Function codes: DISP, CLEAR, EXIT
*&---------------------------------------------------------------------*
PROGRAM zcustomer_module_pool.

TABLES: kna1.

"-----------------------------
" Types
"-----------------------------
TYPES: BEGIN OF ty_customer,
         name1   TYPE kna1-name1,
         city1   TYPE kna1-ort01,
         country TYPE kna1-land1,
       END OF ty_customer.

"-----------------------------
" Global screen-bound data
"-----------------------------
DATA: gv_kunnr    TYPE kna1-kunnr,
      gs_customer TYPE ty_customer,
      gv_okcode   TYPE sy-ucomm,
      gv_save_ok  TYPE sy-ucomm.

"-----------------------------
" Controller class declaration
"-----------------------------
CLASS zcl_customer_controller DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      " Orchestrator method used by PAI DISPLAY action
      get_customer_data
        IMPORTING
          iv_kunnr       TYPE kna1-kunnr
        EXPORTING
          es_customer    TYPE ty_customer
          ev_success     TYPE abap_bool
          ev_error_text  TYPE string,

      " DB-access method: reads customer row from KNA1
      fetch_customer_data
        IMPORTING
          iv_kunnr       TYPE kna1-kunnr
        EXPORTING
          es_customer    TYPE ty_customer
          ev_found       TYPE abap_bool,

      " Utility method: resets screen data
      clear_screen
        CHANGING
          cv_kunnr       TYPE kna1-kunnr
          cs_customer    TYPE ty_customer.

  PRIVATE SECTION.
    DATA: ms_customer TYPE ty_customer.
ENDCLASS.

"-----------------------------
" Controller class implementation
"-----------------------------
CLASS zcl_customer_controller IMPLEMENTATION.

  METHOD get_customer_data.
    CLEAR: es_customer, ev_error_text.
    ev_success = abap_false.

    " Validation: Customer number is mandatory
    IF iv_kunnr IS INITIAL.
      ev_error_text = 'Customer number is required.'.
      RETURN.
    ENDIF.

    " Retrieve data from database via dedicated method
    DATA(lv_found) = abap_false.
    me->fetch_customer_data(
      EXPORTING
        iv_kunnr    = iv_kunnr
      IMPORTING
        es_customer = es_customer
        ev_found    = lv_found
    ).

    " Business result handling
    IF lv_found = abap_false.
      ev_error_text = |Customer { iv_kunnr } not found.|.
      RETURN.
    ENDIF.

    ev_success = abap_true.
  ENDMETHOD.

  METHOD fetch_customer_data.
    CLEAR: es_customer.
    ev_found = abap_false.

    " NOTE: KUNNR in database is ALPHA-formatted; normalize input first
    DATA(lv_kunnr) = iv_kunnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_kunnr
      IMPORTING
        output = lv_kunnr.

    " Single-record read from KNA1 (customer general data)
    SELECT SINGLE
      name1,
      ort01,
      land1
      FROM kna1
      WHERE kunnr = @lv_kunnr
      INTO @DATA(ls_kna1).

    IF sy-subrc = 0.
      es_customer-name1   = ls_kna1-name1.
      es_customer-city1   = ls_kna1-ort01.
      es_customer-country = ls_kna1-land1.

      " Keep internal state encapsulated in class
      ms_customer = es_customer.
      ev_found = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD clear_screen.
    CLEAR: cv_kunnr, cs_customer, ms_customer.
  ENDMETHOD.

ENDCLASS.

"-----------------------------
" Controller object instance
"-----------------------------
DATA go_controller TYPE REF TO zcl_customer_controller.

"-----------------------------
" PBO modules for screen 0100
"-----------------------------
MODULE status_0100 OUTPUT.
  " Instantiate controller once
  IF go_controller IS INITIAL.
    go_controller = NEW zcl_customer_controller( ).
  ENDIF.

  " Set PF-STATUS and title for screen 0100
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR  'TITLE_0100'.
ENDMODULE.

MODULE prepare_screen_0100 OUTPUT.
  " Placeholder for dynamic screen modifications if needed in future.
ENDMODULE.

"-----------------------------
" PAI module for screen 0100
"-----------------------------
MODULE user_command_0100 INPUT.
  gv_save_ok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_save_ok.
    WHEN 'DISP'. " DISPLAY button
      DATA: ls_customer   TYPE ty_customer,
            lv_success    TYPE abap_bool,
            lv_error_text TYPE string.

      go_controller->get_customer_data(
        EXPORTING
          iv_kunnr      = gv_kunnr
        IMPORTING
          es_customer   = ls_customer
          ev_success    = lv_success
          ev_error_text = lv_error_text
      ).

      IF lv_success = abap_true.
        gs_customer = ls_customer.
      ELSE.
        MESSAGE lv_error_text TYPE 'E'.
      ENDIF.

    WHEN 'CLEAR'. " CLEAR button
      go_controller->clear_screen(
        CHANGING
          cv_kunnr    = gv_kunnr
          cs_customer = gs_customer
      ).

    WHEN 'EXIT' OR 'BACK' OR 'CANC'. " EXIT button / standard navigation
      LEAVE PROGRAM.

    WHEN OTHERS.
      " No action
  ENDCASE.
ENDMODULE.

"---------------------------------------------------------------------*
" Screen 0100 Flow Logic (maintained in Screen Painter)
"---------------------------------------------------------------------*
" PROCESS BEFORE OUTPUT.
"   MODULE status_0100.
"   MODULE prepare_screen_0100.
"*
" PROCESS AFTER INPUT.
"   MODULE user_command_0100.
"---------------------------------------------------------------------*
