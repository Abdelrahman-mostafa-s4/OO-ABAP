*&---------------------------------------------------------------------*
*& Report Y_REMEBER_ABSTRACT_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Y_REMEBER_ABSTRACT_CLASS.
PARAMETERS : P_SALE TYPE VBAK-vbeln,
             P_1 TYPE C RADIOBUTTON GROUP R1,
             P_2 TYPE C RADIOBUTTON GROUP R1.


DATA : OERDAT TYPE VBAK-erdat,
       OERNAM TYPE VBAK-ERNAM,
       OERZET TYPE VBAK-erzet .
CLASS DOCUMENT_DETAILS DEFINITION ABSTRACT.
  PUBLIC SECTION.
  METHODS DISPLAY_DETAILS ABSTRACT IMPORTING PVBELN TYPE VBAK-vbeln
                                    EXPORTING PERDAT TYPE VBAK-erdat
                                              PERNAM TYPE VBAK-ERNAM
                                              PERZET TYPE VBAK-erzet.
  ENDCLASS.


  CLASS DOCUMENT_DETAILS IMPLEMENTATION.

    ENDCLASS.


  CLASS SALES_DOCUMNET_DETAILS DEFINITION INHERITING FROM DOCUMENT_DETAILS.
    PUBLIC SECTION.
    METHODS DISPLAY_DETAILS REDEFINITION.
    ENDCLASS.

    CLASS SALES_DOCUMNET_DETAILS IMPLEMENTATION.
     METHOD display_details.
       SELECT SINGLE ERDAT , ERNAM , ERZET
       FROM VBAK
       INTO (@PERDAT  , @PERNAM  , @PERZET )
       WHERE VBELN = @P_SALE.


       ENDMETHOD.

      ENDCLASS.


  CLASS BILLING_DOCUMNET_DETAILS DEFINITION INHERITING FROM DOCUMENT_DETAILS.
    PUBLIC SECTION.
    METHODS DISPLAY_DETAILS REDEFINITION.
    ENDCLASS.

    CLASS BILLING_DOCUMNET_DETAILS IMPLEMENTATION.
     METHOD display_details.
       SELECT SINGLE ERDAT , ERNAM , ERZET
       FROM VBRK
       INTO (@PERDAT  , @PERNAM  , @PERZET )
       WHERE VBELN = @P_SALE.


       ENDMETHOD.

      ENDCLASS.

START-OF-SELECTION.

IF p_1 = 'X'.


DATA : OBJECT TYPE REF TO SALES_DOCUMNET_DETAILS.

CREATE OBJECT object.

OBJECT->display_details(
EXPORTING
  pvbeln = P_SALE

  IMPORTING
    perdat = OERDAT
    pernam = OERNAM
    perzet = OERZET

).

WRITE : / OERDAT ,
          OERNAM ,
          OERZET.

ELSE .

  DATA : OBJECT_2 TYPE REF TO BILLING_DOCUMNET_DETAILS.

CREATE OBJECT OBJECT_2.

OBJECT_2->display_details(
EXPORTING
  pvbeln = P_SALE

  IMPORTING
    perdat = OERDAT
    pernam = OERNAM
    perzet = OERZET

).

WRITE : / OERDAT ,
          OERNAM ,
          OERZET.


ENDIF.