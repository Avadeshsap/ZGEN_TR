CLASS lhc_bokkingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingSupplId FOR DETERMINE ON SAVE
      IMPORTING keys FOR BokkingSupplement~setBookingSupplId.

ENDCLASS.

CLASS lhc_bokkingsupplement IMPLEMENTATION.

  METHOD setBookingSupplId.


   DATA : max_bookingsupplid TYPE /dmo/booking_supplement_id,
          bookingsuppliment TYPE STRUCTURE FOR read RESULT ZGEN_I_BKSUPPL,
          bookingsuppl_update type TABLE FOR UPDATE ZGEN_I_TRAVEL\\BokkingSupplement.



READ ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
ENTITY BokkingSupplement BY \_Booking
FIELDS ( BookingUuid )
WITH CORRESPONDING #( keys )
RESULT DATA(bookings).


READ ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
ENTITY Booking BY \_Bksuppl
FIELDS ( BookingSupplementId )
WITH CORRESPONDING #( bookings )
LINK DATA(bookingsuppl_links)
RESULT DATA(bookingsupplements).





LOOP AT bookings INTO data(booking).

max_bookingsupplid = '50'.


LOOP at bookingsuppl_links INTO data(bookingsuppl_link) USING key id  WHERE source-%tky = booking-%tky.



   bookingsuppliment = bookingsupplements[ key id %tky = bookingsuppl_link-target-%tky ].


     IF bookingsuppliment-BookingSupplementId > max_bookingsupplid .


     max_bookingsupplid  = bookingsuppliment-BookingSupplementId.

     ENDIF.


ENDLOOP.



LOOP AT bookingsuppl_links into bookingsuppl_link using key id where source-%tky = booking-%tky.


  bookingsuppliment = bookingsupplements[ key id %tky = bookingsuppl_link-target-%tky ].

  if bookingsuppliment-BookingSupplementId is INITIAL.

  max_bookingsupplid += 1.

  APPEND VALUE #( %tky = bookingsuppliment-%tky
                   BookingSupplementId = max_bookingsupplid ) to bookingsuppl_update.


  ENDIF.

ENDLOOP.

ENDLOOP.


MODIFY ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
ENTITY BokkingSupplement
UPDATE FIELDS ( BookingSupplementId )
WITH bookingsuppl_update.



ENDMETHOD.

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.
    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingDate.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD setBookingId.


  DATA : max_bookingid type /dmo/booking_id,
         booking type STRUCTURE FOR READ RESULT ZGEN_I_BOOKING,
         bookings_update type table for update ZGEN_I_TRAVEL\\BOOKING.



 "Read all the travels for the requested Bookings
 READ ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
 ENTITY Booking by \_travel
 FIELDS ( TravelUuid )
 with CORRESPONDING #( keys )
 RESULT DATA(travels).


 "Read all the Bookings for all affected travels
 READ ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
 ENTITY Travel BY \_Booking
 FIELDS ( BookingId )
 WITH CORRESPONDING #( travels )
 LINK DATA(booking_links)
 RESULT DATA(bookings).



 "Process the Travels data
 LOOP AT travels INTO data(travel).


 max_bookingid = '0000'.



 LOOP AT booking_links into data(booking_link) using key id where source-%tky = travel-%tky.


 booking = bookings[ key id %tky = booking_link-target-%tky ].

 if booking-BookingId > max_bookingid.

 max_bookingid = booking-BookingId .

 endif.

 ENDLOOP.




 LOOP AT booking_links into booking_link using key  id where
                                        source-%tky = travel-%tky.
 "Read Bookings table
     booking = bookings[ key id %tky = booking_link-target-%tky ].

  IF booking-BookingId is INITIAL.

  max_bookingid += 1.

  APPEND VALUE #( %tky = booking-%tky
                   BookingId = max_bookingid ) to bookings_update.

  ENDIF.

 ENDLOOP.

 ENDLOOP.



 MODIFY ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
 ENTITY Booking
 UPDATE FIELDS ( BookingId )
 WITH bookings_update.


  ENDMETHOD.






  METHOD setBookingDate.

 READ ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
 ENTITY Booking
 FIELDS ( BookingDate )
 WITH CORRESPONDING #( keys )
 RESULT DATA(Bookings).

 DELETE bookings WHERE BookingDate IS NOT INITIAL.

 CHECK bookings IS NOT INITIAL.

 LOOP at bookings ASSIGNING FIELD-SYMBOL(<booking>).

 <booking>-BookingDate  = cl_abap_context_info=>get_system_date( ).

 ENDLOOP.


 MODIFY ENTITIES OF ZGEN_I_TRAVEL IN LOCAL MODE
 ENTITY  Booking
 UPDATE FIELDS ( BookingDate )
 WITH CORRESPONDING #( Bookings ).

  ENDMETHOD.

ENDCLASS.

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
