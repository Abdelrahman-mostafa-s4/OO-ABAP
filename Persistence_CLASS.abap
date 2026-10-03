*&---------------------------------------------------------------------*
*& Report Z_PERSISTENCE_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_persistence_class.

DATA : lo_object TYPE REF TO zcl_persistence_class_p1,
       lo_agent  TYPE REF TO zca_persistence_class_p1,
       lv_vbeln  TYPE vbak-vbeln,
       G_ernam   TYPE vbak-ernam,
       G_erdat   TYPE vbak-erdat,
       G_erzet   TYPE vbak-erzet.

PARAMETERS : p_vbeln TYPE vbak-vbeln OBLIGATORY,
             p_ernam TYPE vbak-ernam,
             p_erdat TYPE vbak-erdat,
             p_erzet TYPE vbak-erzet,
             p1      TYPE c RADIOBUTTON GROUP r1,
             p2      TYPE c RADIOBUTTON GROUP r1 DEFAULT 'X',
             p3      TYPE c RADIOBUTTON GROUP r1.



START-OF-SELECTION.

  IF p1 = 'X'.

    lo_agent = zca_persistence_class_p1=>agent.
    TRY.
        CALL METHOD lo_agent->create_persistent
          EXPORTING
            i_vbeln = p_vbeln
          RECEIVING
            result  = lo_object.
      CATCH cx_os_object_existing.
    ENDTRY.

    TRY.
        CALL METHOD lo_object->set_erdat
          EXPORTING
            i_erdat = p_erdat.
      CATCH cx_os_object_not_found.
    ENDTRY.

    TRY.
        CALL METHOD lo_object->set_ernam
          EXPORTING
            i_ernam = p_ernam.
      CATCH cx_os_object_not_found.
    ENDTRY.

    TRY.
        CALL METHOD lo_object->set_erzet
          EXPORTING
            i_erzet = p_erzet.
      CATCH cx_os_object_not_found.
    ENDTRY.

    COMMIT WORK.
  ENDIF.

  IF p3 = 'X'.
    lo_agent = zca_persistence_class_p1=>agent.
    TRY.
        CALL METHOD lo_agent->delete_persistent
          EXPORTING
            i_vbeln = p_vbeln.
      CATCH cx_os_object_not_existing.
    ENDTRY.

    COMMIT WORK.


  ENDIF.



  IF p2 = 'X'.
    lo_agent = zca_persistence_class_p1=>agent.
    TRY.
    CALL METHOD lo_agent->get_persistent
      EXPORTING
        i_vbeln = P_VBELN
      receiving
        result  = LO_OBJECT
        .
      CATCH cx_os_object_not_found.
    ENDTRY.

    TRY.
    CALL METHOD lo_object->set_ernam
      EXPORTING
        i_ernam = p_ernam
        .
      CATCH cx_os_object_not_found.
    ENDTRY.

       TRY.
    CALL METHOD lo_object->set_erdat
      EXPORTING
        i_erdat = P_ERDAT
        .
      CATCH cx_os_object_not_found.
    ENDTRY.

    TRY.
    CALL METHOD lo_object->set_erzet
      EXPORTING
        i_erzet = P_ERZET
        .
      CATCH cx_os_object_not_found.
    ENDTRY.

    COMMIT WORK.

  ENDIF.

AT SELECTION-SCREEN.

  IF p1 = 'X'.
    lo_agent = zca_persistence_class_p1=>agent.

*    SELECT SINGLE VBELN
*      FROM YZSTRHEAD
*      INTO LV_VBELN
*      WHERE VBELN = P_VBELN.
*      IF SY-subrc = 0.
*        MESSAGE E001(YMSG) WITH P_VBELN .
*      ENDIF.

    TRY.
        CALL METHOD lo_agent->get_persistent
          EXPORTING
            i_vbeln = p_vbeln
          RECEIVING
            result  = lo_object.
      CATCH cx_os_object_not_found.
    ENDTRY.

    IF lo_object IS NOT INITIAL.
      MESSAGE e001(ymsg) WITH p_vbeln .
    ELSE.
      MESSAGE s004(ymsg) WITH p_vbeln.

    ENDIF.
  ENDIF.

  IF p3 ='X'.
    lo_agent = zca_persistence_class_p1=>agent.
    TRY.
        CALL METHOD lo_agent->get_persistent
          EXPORTING
            i_vbeln = p_vbeln
          RECEIVING
            result  = lo_object.
      CATCH cx_os_object_not_found.
    ENDTRY.

    IF lo_object IS INITIAL.
      MESSAGE e002(ymsg) WITH p_vbeln.
    ELSE.
      MESSAGE s003(ymsg) WITH p_VBELN.
    ENDIF.
  ENDIF.

  IF p2 = 'X'.
    lo_agent = zca_persistence_class_p1=>agent.
    TRY.
        CALL METHOD lo_agent->get_persistent
          EXPORTING
            i_vbeln = P_vbeln
          RECEIVING
            result  = lo_object.
      CATCH cx_os_object_not_found.
    ENDTRY.

    IF lo_object IS INITIAL.
      MESSAGE e005(ymsg) WITH p_vbeln.
    ENDIF.


    IF lo_object IS NOT INITIAL.
      TRY.
          CALL METHOD lo_object->get_ernam
            RECEIVING
              result = G_ernam.
        CATCH cx_os_object_not_found.
      ENDTRY.

      TRY.
          CALL METHOD lo_object->get_erdat
            RECEIVING
              result = G_erdat.
        CATCH cx_os_object_not_found.
      ENDTRY.

      TRY.
          CALL METHOD lo_object->get_erzet
            RECEIVING
              result = G_erzet.
        CATCH cx_os_object_not_found.
      ENDTRY.

    ENDIF.
  ENDIF
  .

  AT SELECTION-SCREEN OUTPUT.
    IF P2 = 'X'.
    p_ernam = G_ernam.
    p_erdat = G_erdat.
    p_erzet = G_erzet.
    ENDIF.