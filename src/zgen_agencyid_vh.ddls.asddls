@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency ID ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGEN_AGENCYID_VH as select from /DMO/I_Agency_StdVH
{
    key AgencyID,
    Name,
    Street,
    PostalCode,
    City,
    CountryCode,
    CountryCodeText,
    PhoneNumber,
    EMailAddress,
    WebAddress
}
