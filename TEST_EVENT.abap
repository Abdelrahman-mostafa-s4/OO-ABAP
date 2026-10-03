*&---------------------------------------------------------------------*
*& Report Y_RECAP_EVENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT y_recap_events.

PARAMETERS : p_vbeln TYPE vbak-vbeln.

CLASS document_details DEFINITION.
  PUBLIC SECTION.
    METHODS display_document_details IMPORTING pvbeln TYPE vbak-vbeln
                                     EXPORTING pernam TYPE vbak-ernam
                                               perdat TYPE vbak-erdat
                                               perzet TYPE vbak-erzet.

    EVENTS where_input.

ENDCLASS.


CLASS document_details IMPLEMENTATION.
  METHOD display_document_details .
    IF pvbeln IS INITIAL.
      RAISE EVENT where_input.
    ELSE.
      SELECT SINGLE ernam , erdat , erzet
        FROM vbak
        INTO ( @pernam , @perdat , @perzet )
        WHERE vbeln = @pvbeln.

    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS message FOR EVENT where_input OF document_details.
ENDCLASS.

CLASS event_handler IMPLEMENTATION.
  METHOD message .
    WRITE 'WHERE YOUR INPUT SIR?'.
  ENDMETHOD.

ENDCLASS.



DATA : object_1 TYPE REF TO document_details,
       obhect_2 TYPE REF TO event_handler,
       p_ernam  TYPE vbak-ernam,
       p_erdat  TYPE vbak-erdat,
       p_erzet  TYPE vbak-erzet.

START-OF-SELECTION.

  CREATE OBJECT : object_1 , obhect_2.


  SET HANDLER obhect_2->message FOR object_1.

object_1->display_document_details(
EXPORTING
  pvbeln = p_vbeln
  IMPORTING
    perdat = p_erdat
    pernam = p_ernam
    perzet = p_erzet

 ).

 WRITE : / p_erdat,
           p_ernam,
           p_erzet.