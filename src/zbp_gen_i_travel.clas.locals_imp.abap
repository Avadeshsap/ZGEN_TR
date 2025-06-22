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

ENDCLASS.
