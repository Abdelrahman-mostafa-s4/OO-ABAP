*&---------------------------------------------------------------------*
*& Report ZLOCAL_ABSTRACT_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZLOCAL_INTERFAVE.
PARAMETERS: v_VBELN TYPE VBAK-vbeln,
            P_1 TYPE C RADIOBUTTON GROUP R1,
            P_2 TYPE C RADIOBUTTON GROUP R1.



INTERFACE DOCUMENT_DETAILS.
METHODS : DISPLAY_DOCUMENT_DETAILS IMPORTING P_VBELN TYPE VBAK-vbeln
                                   EXPORTING P_ERNAM TYPE VBAK-ernam
                                             P_ERDAT TYPE VBAK-ERDAT
                                             P_ERZET TYPE VBAK-erzet.
ENDINTERFACE.

CLASS SALES_DOCUMNET_DETAILS DEFINITION .
  PUBLIC SECTION.
  INTERFACES DOCUMENT_DETAILS.
  ENDCLASS.

  CLASS SALES_DOCUMNET_DETAILS IMPLEMENTATION .
    METHOD document_details~DISPLAY_DOCUMENT_DETAILS .
      SELECT SINGLE ernam , erzet , erdat
      FROM VBAK
      INTO ( @P_ERNAM , @P_ERZET , @P_ERDAT )
      WHERE VBELN = @P_VBELN.

      ENDMETHOD.
    ENDCLASS.


CLASS BILLING_DOCUMNET_DETAILS DEFINITION.
  PUBLIC SECTION.
  INTERFACES DOCUMENT_DETAILS.
  ENDCLASS.

  CLASS BILLING_DOCUMNET_DETAILS IMPLEMENTATION .
    METHOD document_details~DISPLAY_DOCUMENT_DETAILS.
      SELECT SINGLE ernam , erzet , erdat
      FROM VBRK
      INTO ( @P_ERNAM , @P_ERZET , @P_ERDAT )
      WHERE VBELN = @P_VBELN.
      ENDMETHOD.
    ENDCLASS.

DATA : OBJ_1 TYPE REF TO sales_documnet_details,
       OBJ_2 TYPE REF TO billing_documnet_details,
       V_ERDAT TYPE VBAK-erdat,
       V_ERNAM TYPE VBAK-ernam,
       V_ERZET TYPE VBAK-erzet.

START-OF-SELECTION.

    IF P_1 = 'X'.
      CREATE OBJECT obj_1.
      obj_1->document_details~DISPLAY_DOCUMENT_DETAILS(
      EXPORTING
        p_vbeln = v_VBELN

      IMPORTING
         p_ernam = V_ERNAM
         p_erzet = V_ERZET
         p_erdat = V_ERDAT

      ).


      WRITE : / 'SALES DOCUMENT DETAILS',
              / V_ERNAM ,
              / V_ERZET ,
              / V_ERDAT .


    ENDIF.

  IF P_2 = 'X'.
CREATE OBJECT obj_2.
obj_2->document_details~DISPLAY_DOCUMENT_DETAILS(
EXPORTING
  p_vbeln = v_VBELN

IMPORTING
   p_ernam = V_ERNAM
   p_erzet = V_ERZET
   p_erdat = V_ERDAT

).

      WRITE : / 'BILLING DOCUMENT DETAILS',
              / V_ERNAM ,
              / V_ERZET ,
              / V_ERDAT .

ENDIF.