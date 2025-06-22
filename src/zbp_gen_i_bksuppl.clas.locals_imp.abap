CLASS lhc_BokkingSupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setBookingSupplId FOR DETERMINE ON SAVE
      IMPORTING keys FOR BokkingSupplement~setBookingSupplId.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BokkingSupplement~calculateTotalPrice.

ENDCLASS.

CLASS lhc_BokkingSupplement IMPLEMENTATION.

  METHOD setBookingSupplId.
    DATA : max_bookingsupplid  TYPE /dmo/booking_supplement_id,
           bookingsuppliment   TYPE STRUCTURE FOR READ RESULT zgen_i_bksuppl,
           bookingsuppl_update TYPE TABLE FOR UPDATE zgen_i_travel\\BokkingSupplement.



    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
    ENTITY BokkingSupplement BY \_Booking
    FIELDS ( BookingUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).


    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
    ENTITY Booking BY \_Bksuppl
    FIELDS ( BookingSupplementId )
    WITH CORRESPONDING #( bookings )
    LINK DATA(bookingsuppl_links)
    RESULT DATA(bookingsupplements).





    LOOP AT bookings INTO DATA(booking).

      max_bookingsupplid = '50'.


      LOOP AT bookingsuppl_links INTO DATA(bookingsuppl_link) USING KEY id  WHERE source-%tky = booking-%tky.



        bookingsuppliment = bookingsupplements[ KEY id %tky = bookingsuppl_link-target-%tky ].


        IF bookingsuppliment-BookingSupplementId > max_bookingsupplid .


          max_bookingsupplid  = bookingsuppliment-BookingSupplementId.

        ENDIF.


      ENDLOOP.



      LOOP AT bookingsuppl_links INTO bookingsuppl_link USING KEY id WHERE source-%tky = booking-%tky.


        bookingsuppliment = bookingsupplements[ KEY id %tky = bookingsuppl_link-target-%tky ].

        IF bookingsuppliment-BookingSupplementId IS INITIAL.

          max_bookingsupplid += 1.

          APPEND VALUE #( %tky = bookingsuppliment-%tky
                           BookingSupplementId = max_bookingsupplid ) TO bookingsuppl_update.


        ENDIF.

      ENDLOOP.

    ENDLOOP.


    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
    ENTITY BokkingSupplement
    UPDATE FIELDS ( BookingSupplementId )
    WITH bookingsuppl_update.



  ENDMETHOD.

  METHOD calculateTotalPrice.
    READ ENTITIES OF zgen_i_travel IN LOCAL MODE
         ENTITY BokkingSupplement BY \_Travel
         FIELDS ( TravelUuid )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    MODIFY ENTITIES OF zgen_i_travel IN LOCAL MODE
           ENTITY Travel
           EXECUTE reCalcTotalProce
           FROM CORRESPONDING #( travels ).



  ENDMETHOD.

ENDCLASS.
