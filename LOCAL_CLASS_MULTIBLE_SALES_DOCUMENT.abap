*&---------------------------------------------------------------------*
*& Report ZLCLCLASS_MULT_SALES_DOC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZLCLCLASS_MULT_SALES_DOC.
TABLES : VBAK.

SELECT-OPTIONS VL_VBELN FOR VBAK-vbeln .


CLASS DISPLAY_SALES_DOCUMENT_DETAILS DEFINITION.
  PUBLIC SECTION.
  METHODS : GET_DATA IMPORTING SVBELN TYPE ZTABL_MULT_SALES_DOC_LCL_CLASS
                     EXPORTING IT_OUTPUT TYPE ZTSTR_MULT_DETAILS_SALES_LOCAL
                     EXCEPTIONS WRONG.

  ENDCLASS.


  CLASS DISPLAY_SALES_DOCUMENT_DETAILS IMPLEMENTATION.
    METHOD GET_DATA .

      TYPES : BEGIN OF ST_HEADER,
        VBELN TYPE VBAK-vbeln ,
        ERDAT TYPE VBAK-erdat ,
        ERZET TYPE VBAK-erzet ,
        ERNAM TYPE VBAK-ernam,
        END OF ST_HEADER.

        DATA : IT_HEADER TYPE TABLE OF ST_HEADER,
               WA_HEADER TYPE ST_HEADER.

        TYPES : BEGIN OF ST_ITEM,
          VBELN TYPE VBAP-vbeln,
          POSNR TYPE VBAP-posnr,
          MATNR TYPE VBAP-matnr,
          END OF ST_ITEM.

          DATA : IT_ITEM TYPE TABLE OF ST_ITEM,
                 WA_ITEM TYPE ST_ITEM.

          DATA : WA_OUTPUT TYPE LINE OF ZTSTR_MULT_DETAILS_SALES_LOCAL.

          SELECT VBELN ,
                 ERDAT ,
                 ERZET ,
                 ERNAM
            FROM VBAK
            INTO TABLE @IT_HEADER
            WHERE VBELN IN @SVBELN.


            IF IT_HEADER IS NOT INITIAL .
              SELECT VBELN ,
                     POSNR ,
                     MATNR
                FROM VBAP
                INTO TABLE @it_item
                FOR ALL ENTRIES IN @IT_HEADER
                WHERE VBELN = @IT_HEADER-vbeln.

            ENDIF.
       LOOP AT  it_header INTO wa_header.
         WA_OUTPUT-vbeln = wa_header-vbeln.
         WA_OUTPUT-erdat = wa_header-erdat.
         WA_OUTPUT-erzet = wa_header-erzet.
         WA_OUTPUT-ernam = wa_header-ernam.
         READ TABLE IT_ITEM INTO WA_ITEM WITH KEY VBELN = wa_header-vbeln.
         WA_OUTPUT-posnr = WA_ITEM-posnr.
         WA_OUTPUT-matnr = WA_ITEM-matnr.
         APPEND WA_OUTPUT TO it_output.
         CLEAR WA_OUTPUT.
       ENDLOOP.

       IF SY-subrc <> 0.
         RAISE wrong.

       ENDIF.

      ENDMETHOD.

    ENDCLASS.

START-OF-SELECTION.

    DATA : LO_OBJECT TYPE REF TO DISPLAY_SALES_DOCUMENT_DETAILS .

    CREATE OBJECT LO_OBJECT .

    DATA : IT_FINAL TYPE ZTSTR_MULT_DETAILS_SALES_LOCAL,
           WA_FINAL TYPE LINE OF ZTSTR_MULT_DETAILS_SALES_LOCAL.

    lo_object->get_data(
    EXPORTING
      svbeln = VL_VBELN[]

      IMPORTING
        it_output = IT_FINAL
    EXCEPTIONS
      wrong = 1


    ).

    IF SY-subrc = 0 .
      LOOP AT IT_FINAL INTO WA_FINAL.
        WRITE : / WA_FINAL-vbeln , WA_FINAL-erdat ,  WA_FINAL-ernam , WA_FINAL-erzet , WA_FINAL-matnr , WA_FINAL-posnr.
      ENDLOOP.

      ELSE.
        MESSAGE E000(YMSG).

    ENDIF.