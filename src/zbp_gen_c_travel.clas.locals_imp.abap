CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD augment_create.

    DATA: travel_create TYPE TABLE FOR CREATE zgen_i_travel.

    travel_create = CORRESPONDING #( entities ).
    LOOP AT travel_create ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-AgencyId = '070012'.
      <travel>-CustomerId  = '1'.
      <travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <travel>-%control-AgencyId = if_abap_behv=>mk-on.
      <travel>-%control-CustomerId = if_abap_behv=>mk-on.
      <travel>-%control-BeginDate = if_abap_behv=>mk-on.
    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF zgen_i_travel ENTITY Travel CREATE FROM travel_create.
  ENDMETHOD.

ENDCLASS.
