CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS setTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelID.
    METHODS setStaustoOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStaustoOpen.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setTravelID.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).


    DELETE lt_travel WHERE TravelId IS NOT INITIAL.

    SELECT SINGLE FROM zgen_travel FIELDS MAX( travel_id ) INTO @DATA(lv_max_travelId).

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
     ENTITY Travel
     UPDATE FIELDS ( TravelId )
     WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO lv_index (
                   %tky  = ls_travel-%tky
                   TravelId = lv_max_travelId + lv_index ) ).


  ENDMETHOD.

  METHOD setStaustoOpen.
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
          ENTITY Travel
          FIELDS ( OverallStatus )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_travel).


    DELETE lt_travel WHERE OverallStatus IS NOT INITIAL.

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR ls_travel IN lt_travel
                      ( %tky = ls_travel-%tky
                        OverallStatus = 'O' ) ).


  ENDMETHOD.

ENDCLASS.
