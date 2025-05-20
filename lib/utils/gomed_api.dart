class Bbapi {

  static const String baseUrl = "http://97.74.93.26:3000";
  static const String login = "$baseUrl/user/login";
  static const String refreshToken = "$baseUrl/auth/refresh-token";
  static const String getService = "$baseUrl/services/getallservices";
  static const String getdistributor = "$baseUrl/admin/distributors";
  static const String updateDistributor ="$baseUrl/distributor/update";
  static const String getusers = "$baseUrl/admin/users";
  static const String getServiceengineers = "$baseUrl/admin/service-engineers";
  static const String addServiceengineer = "$baseUrl/admin/add-service-engineer";
  static const String updateServiceEngineer = "$baseUrl/distributor/updateServiceEngineer";
  static const String deleteServiceEngineer = "$baseUrl/distributor/deleteServiceEngineer";
  static const String updateAdminProfile = "$baseUrl/user/updateProfile";
  static const String deleteAdminProfile = "$baseUrl/user/deleteProfile";
  static const String getproductslist = "$baseUrl/products/getallproducts";
  static const String getserviceslist = "$baseUrl/services/getallservices";
  static const String updateproductapi= "$baseUrl/servicebooking/admin/assign-engineer";
  static const String updateserviceapi = "$baseUrl/services/admin/activate";
  static const String deleteProduct = "$baseUrl/products/delete";
  static const String deleteService = "$baseUrl/services/deleteservice";
  static const String getBookingService = "$baseUrl/servicebooking/list";

  static const String sparepartAdd = "$baseUrl/spareparts/add";
  static const String sparepartGet = "$baseUrl/spareparts/list";
  static const String sparepartupdate = "$baseUrl/spareparts/update";
  static const String sparepartdelete = "$baseUrl/spareparts/delete";
  static const String serviceAdd = "$baseUrl/services/createservice";
  // static const String getService = "$baseUrl/services/getservices";
  static const String serviceupdate= "$baseUrl/services/updateservice";
  // static const String deleteService = "$baseUrl/services/deleteservice";
  static const String add = "$baseUrl/products/admin/product/add";
  static const String getProduct = "$baseUrl/products/adminAddProducts";
  static const String update = "$baseUrl/products/updateproduct";
  static const String delete = "$baseUrl/products/deleteproduct";
  
  
  static const String addcategory = "$baseUrl/products/category/create";
  static const String getcategory = "$baseUrl/products/category/all";
  static const String updatecategory = "$baseUrl/products/category/update";
  static const String deletecategory = "$baseUrl/products/category/delete";

  static const String getRequestedProducts = "$baseUrl/products/all-requested-products";
  static const String updateRequestedProducts = "$baseUrl/products/admin/product/approval";
  static const String adminApprovedProducts = "$baseUrl/products/products/approved";
  
}
