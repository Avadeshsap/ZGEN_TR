CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.


CLASS lhc_Booking IMPLEMENTATION.
  METHOD setBookingDate.
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Booking
         FIELDS ( BookingDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(Bookings).

    DELETE bookings WHERE BookingDate IS NOT INITIAL.

    IF bookings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).

      <booking>-BookingDate = cl_abap_context_info=>get_system_date( ).

    ENDLOOP.

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
           ENTITY Booking
           UPDATE FIELDS ( BookingDate )
           WITH CORRESPONDING #( Bookings ).
  ENDMETHOD.

  METHOD setBookingId.
    DATA max_bookingid   TYPE /dmo/booking_id.
    DATA booking         TYPE STRUCTURE FOR READ RESULT zgen_i_booking.
    DATA bookings_update TYPE TABLE FOR UPDATE zgen_i_travel\\booking.

    " Read all the travels for the requested Bookings
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Booking BY \_travel
         FIELDS ( TravelUuid )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    " Read all the Bookings for all affected travels
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY Travel BY \_Booking
         FIELDS ( BookingId )
         WITH CORRESPONDING #( travels )
         LINK DATA(booking_links)
         RESULT DATA(bookings).

    " Process the Travels data
    LOOP AT travels INTO DATA(travel).

      max_bookingid = '0000'.

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = travel-%tky.

        booking = bookings[ KEY id
                            %tky = booking_link-target-%tky ].

        IF booking-BookingId > max_bookingid.

          max_bookingid = booking-BookingId.

        ENDIF.

      ENDLOOP.

      LOOP AT booking_links INTO booking_link USING KEY id
           WHERE source-%tky = travel-%tky.
        " Read Bookings table
        booking = bookings[ KEY id
                            %tky = booking_link-target-%tky ].

        IF booking-BookingId IS INITIAL.

          max_bookingid += 1.

          APPEND VALUE #( %tky      = booking-%tky
                          BookingId = max_bookingid ) TO bookings_update.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
           ENTITY Booking
           UPDATE FIELDS ( BookingId )
           WITH bookings_update.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
        ENTITY Booking BY \_Travel
        FIELDS ( TravelUuid )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).


    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalProce
    FROM CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.
