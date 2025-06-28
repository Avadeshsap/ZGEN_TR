@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption For Travel'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #CONSUMPTION
@Metadata.allowExtensions: true
define root view entity ZGEN_C_TRAVEL
  provider contract transactional_query
  as projection on ZGEN_I_TRAVEL
{
  key TravelUuid,
      TravelId,
      AgencyId,
      @ObjectModel.text.element: ['CustomerName']
      @UI.textArrangement: #TEXT_FIRST
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      //      concat_with_space( _Customer.FirstName, _Customer.LastName, 2 ) as CustomerName ,
      //      concat( _Customer.FirstName, _Customer.LastName ) as CustomerName,
      _Customer.FirstName as CustomerName,
      /* Associations */
      _Booking : redirected to composition child ZGEN_C_BOOKING

}
