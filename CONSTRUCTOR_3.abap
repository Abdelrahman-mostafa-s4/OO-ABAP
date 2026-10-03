*&---------------------------------------------------------------------*
*& Report Z_CONSTRUCTOR_V4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_constructor_v4.

PARAMETERS p_vbeln TYPE vbak-vbeln.
CLASS document_details DEFINITION.
  PUBLIC SECTION.
    DATA : mv_vbeln TYPE vbak-vbeln.
    METHODS: constructor IMPORTING iv_vbeln TYPE vbak-vbeln.
    METHODS: dispaly EXPORTING ernam TYPE vbak-ernam
                               erdat TYPE vbak-erdat
                               erzet TYPE vbak-erzet .
ENDCLASS.


CLASS document_details IMPLEMENTATION.
  METHOD constructor.
    mv_vbeln = iv_vbeln .
  ENDMETHOD.
  METHOD dispaly .
    SELECT SINGLE ernam , erdat , erzet
      FROM vbak
      INTO ( @ernam , @erdat , @erzet )
      WHERE vbeln = @mv_vbeln.
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  DATA : lo_object   TYPE REF TO document_details,
         lo_object_2 TYPE REF TO document_details,
         out_ernam   TYPE vbak-ernam,
         out_erdat   TYPE vbak-erdat,
         out_erzer   TYPE vbak-erzet.

  CREATE OBJECT lo_object
    EXPORTING
      iv_vbeln = p_vbeln.

  lo_object->dispaly(
  IMPORTING
    ernam = out_ernam
    erdat = out_erdat
    erzet = out_erzer

  ).


  WRITE : / out_ernam ,
            out_erdat ,
            out_erzer ,
            lo_object->mv_vbeln.
  ULINE.
  CREATE OBJECT lo_object_2
    EXPORTING
      iv_vbeln = p_vbeln.

  lo_object_2->dispaly(
  IMPORTING
    ernam = out_ernam
    erdat = out_erdat
    erzet = out_erzer

  ).


  WRITE : / out_ernam ,
            out_erdat ,
            out_erzer ,
            lo_object_2->mv_vbeln.