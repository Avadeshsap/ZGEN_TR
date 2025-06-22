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
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.
    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.
    METHODS reCalcTotalProce FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotalProce.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateagency.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.
    METHODS getdefaultsfordeductdiscounts FOR READ
      IMPORTING keys FOR FUNCTION travel~getdefaultsfordeductdiscounts RESULT result.

    METHODS is_create_granted
      RETURNING VALUE(create_granted) TYPE abap_bool.
    METHODS is_update_granted
      IMPORTING country_code          TYPE land1 OPTIONAL
      RETURNING VALUE(update_granted) TYPE abap_bool.
    METHODS is_delete_granted
      IMPORTING country_code          TYPE land1 OPTIONAL
      RETURNING VALUE(delete_granted) TYPE abap_bool.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

*    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
*     ENTITY Travel
*     ALL FIELDS WITH
*     CORRESPONDING #( keys )
*     RESULT DATA(travels)
*     FAILED failed.
**
**    LOOP AT travels INTO DATA(travel).
**      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.
**        IF  is_update_granted( country_code = 'US' ) = abap_true.
**          APPEND VALUE #( %update = if_abap_behv=>auth-allowed
**                          %tky                   = travel-%tky ) TO result.
**        ELSE.
**          APPEND VALUE #( %update = if_abap_behv=>auth-unauthorized
**                        %tky                   = travel-%tky ) TO result.
**        ENDIF.
**      ENDIF.
**
**    ENDLOOP.
*
*    DATA: update_requested TYPE abap_bool,
*          delete_requested TYPE abap_bool,
*          update_granted   TYPE abap_bool,
*          delete_granted   TYPE abap_bool.
*
*    update_requested = COND #( WHEN requested_authorizations-%update                = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%action-Edit           = if_abap_behv=>mk-on
*                                  THEN abap_true ELSE abap_false ).
*
*    delete_requested = COND #( WHEN requested_authorizations-%delete                = if_abap_behv=>mk-on
*                              THEN abap_true ELSE abap_false ).
*
*    LOOP AT travels INTO DATA(travel).
*
*      IF update_requested EQ abap_true.
*        update_granted = is_update_granted( country_code = CONV #( travel-AgencyId ) ).
*      ENDIF.
*
*      IF delete_requested EQ abap_true.
*        delete_granted = is_delete_granted( ).
*      ENDIF.
*
*
*
*      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed
*                                                  ELSE if_abap_behv=>auth-unauthorized )
*                               del_auth = COND #( WHEN delete_granted = abap_true THEN if_abap_behv=>auth-allowed
*                                                  ELSE if_abap_behv=>auth-unauthorized )
*                           IN
*                            %tky = travel-%tky
*                            %update                = upd_auth
*                            %action-Edit           = upd_auth
*
*                            %delete                = del_auth
*                         ) TO result.

*    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
*    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
*      IF is_create_granted( ) = abap_true.
*        result-%create = if_abap_behv=>auth-allowed.
*      ELSE.
*        result-%create = if_abap_behv=>auth-unauthorized.
*        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
*                                       textid   = /dmo/cm_flight_messages=>not_authorized
*                                       severity = if_abap_behv_message=>severity-error )
*                        %global = if_abap_behv=>mk-on
*                      ) TO reported-travel.
*
*      ENDIF.
*    ENDIF.
*
*    "Edit is treated like update
*    IF requested_authorizations-%update                =  if_abap_behv=>mk-on OR
*       requested_authorizations-%action-Edit           =  if_abap_behv=>mk-on.
*
*      IF  is_update_granted( ) = abap_true.
*        result-%update                =  if_abap_behv=>auth-allowed.
*        result-%action-Edit           =  if_abap_behv=>auth-allowed.
*
*      ELSE.
*        result-%update                =  if_abap_behv=>auth-unauthorized.
*        result-%action-Edit           =  if_abap_behv=>auth-unauthorized.
*
*        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
*                                       textid   = /dmo/cm_flight_messages=>not_authorized
*                                       severity = if_abap_behv_message=>severity-error )
*                        %global = if_abap_behv=>mk-on
*                      ) TO reported-travel.
*
*      ENDIF.
*    ENDIF.
*
*
*    IF requested_authorizations-%delete =  if_abap_behv=>mk-on.
*      IF is_delete_granted( ) = abap_true.
*        result-%delete = if_abap_behv=>auth-allowed.
*      ELSE.
*        result-%delete = if_abap_behv=>auth-unauthorized.
*        APPEND VALUE #( %msg    = NEW /dmo/cm_flight_messages(
*                                       textid   = /dmo/cm_flight_messages=>not_authorized
*                                       severity = if_abap_behv_message=>severity-error )
*                        %global = if_abap_behv=>mk-on
*                       ) TO reported-travel.
*      ENDIF.
*    ENDIF.
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

  METHOD acceptTravel.
    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( OverallStatus )
           WITH VALUE #( FOR ls_key IN keys
                         ( %tky          = ls_key-%tky
                           OverallStatus = 'A' ) ).


    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
     ENTITY Travel
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    result  = VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky
                                                    %param = ls_travel ) ).

  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
            ENTITY Travel
            UPDATE FIELDS ( OverallStatus )
            WITH VALUE #( FOR ls_key IN keys
                          ( %tky          = ls_key-%tky
                            OverallStatus = 'R' ) ).


    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
     ENTITY Travel
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    result  = VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky
                                                    %param = ls_travel ) ).
  ENDMETHOD.

  METHOD deductDiscount.


    DATA travle_for_update TYPE TABLE FOR UPDATE zgen_i_travel.

    DATA(keys_temp) = keys.

    LOOP AT keys_temp ASSIGNING FIELD-SYMBOL(<key_temp>) WHERE %param-discount_percent IS INITIAL OR
                                                               %param-discount_percent > 100 OR
                                                               %param-discount_percent <= 0.


      APPEND VALUE #( %tky =  <key_temp>-%tky ) TO failed-travel.

      APPEND VALUE #( %tky = <key_temp>-%tky
*                      %msg = NEW /dmo/cm_flight_messages(
*                                                       textid = /dmo/cm_flight_messages=>discount_invalid
*                                                       severity = if_abap_behv_message=>severity-error )
                      %msg = new_message_with_text(
                                                       text = 'Invalid discount percentage'
                                                       severity = if_abap_behv_message=>severity-error )

                     %element-BookingFee       = if_abap_behv=>mk-on
                     %action-deductDiscount    = if_abap_behv=>mk-on


                                                        ) TO reported-travel.


      DELETE  keys_temp.

    ENDLOOP.

    CHECK keys_temp IS NOT INITIAL.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS ( BookingFee  )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travels).

    DATA lv_percentage TYPE decfloat16.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).


      DATA(lv_discount_percent) = keys[ KEY id %tky = <fs_travel>-%tky ]-%param-discount_percent.

      lv_percentage = lv_discount_percent / 100.

      DATA(reduced_value) = <fs_travel>-BookingFee * ( lv_percentage ).

      reduced_value = <fs_travel>-BookingFee - reduced_value.

      APPEND VALUE #( %tky = <fs_travel>-%tky
                      BookingFee = reduced_value ) TO travle_for_update.


    ENDLOOP.

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( BookingFee )
        WITH travle_for_update.


    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH
        CORRESPONDING #( keys )
        RESULT DATA(lt_travel_updated).


    result  = VALUE #( FOR ls_travel IN lt_travel_updated ( %tky = ls_travel-%tky
                                                        %param = ls_travel ) ).

  ENDMETHOD.

  METHOD reCalcTotalProce.

    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS ( BookingFee CurrencyCode )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Travel BY \_Booking
         FIELDS ( FlightPrice CurrencyCode )
         WITH CORRESPONDING #( travels )
         RESULT DATA(Bookings)
         LINK DATA(booking_links).

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Booking BY \_Bksuppl
         FIELDS ( Price CurrencyCode )
         WITH CORRESPONDING #( Bookings )
         RESULT DATA(bookingsupplements)
         LINK DATA(bookingsupplement_links).



    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      amounts_per_currencycode =  VALUE #( ( amount = <travel>-BookingFee
                                            currency_code = <travel>-CurrencyCode ) ).

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = <travel>-%tky.
        DATA(booking) = Bookings[ KEY id %tky = booking_link-target-%tky ].

        COLLECT VALUE ty_amount_per_currencycode( amount = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) INTO amounts_per_currencycode.


        LOOP AT bookingsupplement_links INTO DATA(bookingsupplement_link) USING KEY id WHERE source-%tky = booking-%tky.
          DATA(bookingsupplement) = bookingsupplements[ KEY id %tky = bookingsupplement_link-target-%tky ].

          COLLECT VALUE ty_amount_per_currencycode( amount = bookingsupplement-Price
                                                    currency_code = bookingsupplement-CurrencyCode ) INTO amounts_per_currencycode.
        ENDLOOP.

      ENDLOOP.


      DELETE amounts_per_currencycode WHERE currency_code IS INITIAL.

      CLEAR <travel>-TotalPrice.

      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

        "if currency is same in Travel and in amount_per_currencycode
        IF <travel>-CurrencyCode = amount_per_currencycode-currency_code.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.
          "if currency is differ from travel => exchange curreny
          /dmo/cl_flight_amdp=>convert_currency(
           EXPORTING
             iv_amount                   =  amount_per_currencycode-amount
             iv_currency_code_source     =  amount_per_currencycode-currency_code
             iv_currency_code_target     =  <travel>-CurrencyCode
             iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
           IMPORTING
             ev_amount                   = DATA(total_booking_price_per_curr)
          ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        ENDIF.

      ENDLOOP.

    ENDLOOP.



    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
     ENTITY Travel
     UPDATE FIELDS ( TotalPrice )
     WITH CORRESPONDING #( travels ).



  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        EXECUTE reCalcTotalProce
        FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
          FIELDS ( OverallStatus )
          WITH CORRESPONDING #( keys )
        RESULT DATA(travels)
        FAILED failed.


    result = VALUE #( FOR ls_travel IN travels
                          ( %tky                   = ls_travel-%tky

                            %field-BookingFee      = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                             THEN if_abap_behv=>fc-f-read_only
                                                             ELSE if_abap_behv=>fc-f-unrestricted )

                            %action-acceptTravel   = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )
                            %action-rejectTravel   = COND #( WHEN ls_travel-OverallStatus = 'R'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )
                            %action-deductDiscount = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )
                            %assoc-_Booking        = COND #( WHEN ls_travel-OverallStatus = 'R'
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )
                          ) ).
  ENDMETHOD.

  METHOD is_create_granted.
    AUTHORITY-CHECK OBJECT '/DMO/TRVL'
      ID '/DMO/CNTRY' DUMMY
      ID 'ACTVT'      FIELD '01'.
    create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

    "Simulation for full authorization
    create_granted = abap_true.


  ENDMETHOD.


  METHOD is_update_granted.
    "For instance auth
    IF country_code IS SUPPLIED.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
           ID '/DMO/CNTRY' FIELD country_code
           ID 'ACTVT'      FIELD '02'.
      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      update_granted = abap_true.

      " simulation of auth check for demo,
*      CASE country_code.
*        WHEN 'US'.
*          update_granted = abap_true.
*        WHEN OTHERS.
*          update_granted = abap_false.
*      ENDCASE.

      "For global auth

    ELSE.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
      ID '/DMO/CNTRY' DUMMY
      ID 'ACTVT'      FIELD '02'.
      update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      update_granted = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD is_delete_granted.
    "For instance auth
    IF country_code IS SUPPLIED.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
          ID '/DMO/CNTRY' FIELD country_code
          ID 'ACTVT'      FIELD '06'.
      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      delete_granted = abap_true.

      " simulation of auth check for demo,
*      CASE country_code.
*        WHEN 'US'.
*          create_granted = abap_true.
*        WHEN OTHERS.
*          create_granted = abap_false.
*      ENDCASE.

      "For global auth
    ELSE.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'

      ID '/DMO/CNTRY' DUMMY
      ID 'ACTVT'      FIELD '06'.
      delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

      "Simulation for full authorization
      delete_granted = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD validateCustomer.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE customers WHERE customer_id IS INITIAL.


    SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        WHERE customer_id = @customers-customer_id
        INTO TABLE @DATA(valid_customers).


    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(  %tky                 = travel-%tky
                        %state_area          = 'VALIDATE_CUSTOMER'
                      ) TO reported-travel.

      IF travel-CustomerId IS NOT INITIAL AND NOT LIne_exists( valid_customers[ customer_id = travel-CustomerId ] ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg = new_message_with_text(
                                                       text = 'Invalid Customer'
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on

         ) TO reported-travel.

      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateAgency.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS ( AgencyId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    DATA agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.



    agencies = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).

    DELETE agencies WHERE agency_id IS INITIAL.

    CHECK agencies IS NOT INITIAL.

    SELECT FROM /dmo/agency FIELDS agency_id
        FOR ALL ENTRIES IN @agencies
        WHERE agency_id = @agencies-agency_id
        INTO TABLE @DATA(valid_agencies).


    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(  %tky               = travel-%tky
                       %state_area        = 'VALIDATE_AGENCY'
                       ) TO reported-travel.
      IF travel-AgencyId IS NOT INITIAL AND NOT LIne_exists( valid_agencies[ agency_id = travel-AgencyId ] ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
         %state_area        = 'VALIDATE_AGENCY'
                        %msg = new_message_with_text(
                                                       text = 'Invalid Agency'
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-AgencyId = if_abap_behv=>mk-on

         ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
           ENTITY Travel
           FIELDS ( BeginDate EndDate )
           WITH CORRESPONDING #( keys )
           RESULT DATA(travels).


    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(  %tky               = travel-%tky
                       %state_area        = 'VALIDATE_DATES' ) TO reported-travel.
      IF travel-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                                                       text = 'Bagin Date is Blank'
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on

         ) TO reported-travel.
      ENDIF.

      IF travel-EndDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                                                       text = 'End Date is Blank'
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-EndDate = if_abap_behv=>mk-on

         ) TO reported-travel.
      ENDIF.

      IF travel-EndDate < travel-BeginDate AND travel-BeginDate IS NOT INITIAL
                                           AND travel-EndDate IS NOT INITIAL.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg = new_message_with_text(
                                                       text = 'End Date Should not be less than begin date'
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-EndDate = if_abap_behv=>mk-on
                         %element-BeginDate = if_abap_behv=>mk-on

         ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD GetDefaultsFordeductDiscounts.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels)
        FAILED failed.


    LOOP AT travels INTO DATA(travel).

      IF travel-BookingFee >= 1000.
        APPEND VALUE #( %tky = travel-%tky
                        %param-discount_percent = 20 ) TO result.
      ELSE.
        APPEND VALUE #( %tky = travel-%tky
                          %param-discount_percent = 10 ) TO result.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
