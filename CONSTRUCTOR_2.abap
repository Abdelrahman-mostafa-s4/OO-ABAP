*&---------------------------------------------------------------------*
*& Report Z_CONSTRUCTOR_V3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CONSTRUCTOR_V3.
CLASS INFORMATION DEFINITION.
  PUBLIC SECTION.
*  DATA :  mv_emp_id   TYPE i,
*          mv_emp_name TYPE string.

  METHODS : CONSTRUCTOR IMPORTING  iv_id   TYPE i
                                   iv_name TYPE string.


  ENDCLASS.

  CLASS INFORMATION IMPLEMENTATION.
    METHOD constructor.
   WRITE : / iv_id   .
   WRITE : / iv_name .

      ENDMETHOD.

    ENDCLASS.


START-OF-SELECTION.

DATA LO_OBJECT TYPE REF TO INFORMATION.
CREATE OBJECT lo_object
EXPORTING
  iv_id   = 101
  iv_name  = 'MOHAMED'.