*&---------------------------------------------------------------------*
*& Include          ZJK_PG_005_GRAD_PROJ_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& CONTROLS
*&---------------------------------------------------------------------*
CONTROLS tabstrip_film TYPE TABSTRIP.
CONTROLS tabstrip_user TYPE TABSTRIP.

*&---------------------------------------------------------------------*
*& TABLES
*&---------------------------------------------------------------------*
TABLES:
  zjkt_005_admi,                        "Administrator Log In Info.
  zjkt_005_user,                        "User Infomation
  zjkt_005_fminfo,                      "Film Basic Information
  zjkt_005_favfm,                       "User Favourite Films
  zjkt_005_req,                         "User Request
  zjkt_005_fmlist,                      "Film List
  zjkt_005_cinema,                      "Film Cinema
  zjkt_005_tickets.                     "Ticket Information

*&---------------------------------------------------------------------*
*& TYPES
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF typ_graphic,
    line(255) TYPE x,
  END OF typ_graphic,

  BEGIN OF typ_film_out,
    sel      TYPE c1,
    fmname   TYPE zjkt_005_fminfo-fmname,
    fdate    TYPE zjkt_005_fminfo-fdate,
    director TYPE zjkt_005_fminfo-director,
    country  TYPE zjkt_005_fminfo-country,
    type     TYPE zjkt_005_fminfo-type,
    ldro_1   TYPE zjkt_005_fminfo-ldro_1,
    ldro_2   TYPE zjkt_005_fminfo-ldro_2,
    ldro_3   TYPE zjkt_005_fminfo-ldro_3,
  END OF typ_film_out,

  BEGIN OF typ_film,
    fmname   TYPE zjkt_005_fminfo-fmname,
    fdate    TYPE zjkt_005_fminfo-fdate,
    director TYPE zjkt_005_fminfo-director,
    country  TYPE zjkt_005_fminfo-country,
    type     TYPE zjkt_005_fminfo-type,
    ldro_1   TYPE zjkt_005_fminfo-ldro_1,
    ldro_2   TYPE zjkt_005_fminfo-ldro_2,
    ldro_3   TYPE zjkt_005_fminfo-ldro_3,
  END OF typ_film,

  BEGIN OF typ_usr_out,
    sel         TYPE c1,
    ur_name     TYPE zjkt_005_user-ur_name,
    ur_password TYPE zjkt_005_user-ur_password,
    sex         TYPE zjkt_005_user-sex,
    age         TYPE zjkt_005_user-age,
    tel         TYPE zjkt_005_user-tel,
  END OF typ_usr_out,

  BEGIN OF typ_fav_out,
    fmname   TYPE zjkt_005_fminfo-fmname,
    fdate    TYPE zjkt_005_fminfo-fdate,
    director TYPE zjkt_005_fminfo-director,
    country  TYPE zjkt_005_fminfo-country,
    type     TYPE zjkt_005_fminfo-type,
    ldro_1   TYPE zjkt_005_fminfo-ldro_1,
    ldro_2   TYPE zjkt_005_fminfo-ldro_2,
    ldro_3   TYPE zjkt_005_fminfo-ldro_3,
  END OF typ_fav_out,

  BEGIN OF typ_request,
    sel        TYPE c1,
    ur_name    TYPE zjkt_005_req-ur_name,
    sta_reset  TYPE zjkt_005_req-sta_reset,
    sta_remove TYPE zjkt_005_req-sta_remove,
  END OF typ_request,

  BEGIN OF typ_ticket_1,
    sel        TYPE c1,
    ur_name    TYPE zjkt_005_tickets-ur_name,
    fmname     TYPE zjkt_005_tickets-fmname,
    fmcine     TYPE zjkt_005_tickets-fmcine,
    price      TYPE zjkt_005_tickets-price,
    tic_date   TYPE zjkt_005_tickets-tic_date,
    tic_status TYPE zjkt_005_tickets-tic_status,
  END OF typ_ticket_1.

*&---------------------------------------------------------------------*
*& DATA
*&---------------------------------------------------------------------*
DATA:
  ok_code             TYPE sy-ucomm,
  gv_save_ok          TYPE sy-ucomm,
  gv_dynnr            TYPE sy-dynnr,

  "Pic
  container           TYPE REF TO cl_gui_custom_container,
  gv_pic              TYPE REF TO cl_gui_picture,
  gv_graphic_size     TYPE i,
  gs_graphic          TYPE typ_graphic,
  gt_graphic          TYPE STANDARD TABLE OF typ_graphic,
  gv_graphic_url(255) TYPE c,
  gv_result           TYPE i,

  "Admi Log On
  gv_ad_name          TYPE bname,                 "Administrator Name
  gv_ad_password      TYPE zjke_oo5_ad_password,  "Ad Pssword

  "User Sign In
  gv_usr_name         TYPE bname,                 "User Name
  gv_usr_password     TYPE zjke_oo5_ad_password,  "User Password
  gv_usr_password_re  TYPE zjke_oo5_ad_password,  "User Password again
  gv_usr_sex          TYPE zjke_005_sex,          "User Sex
  gv_usr_age          TYPE zjke_005_age,          "User Age
  gv_usr_tel          TYPE zjke_005_tel,          "User Telephone

  "9310 Information Management
  "Film Management
  gt_film_out         TYPE STANDARD TABLE OF typ_film_out,
  gt_film_copy        TYPE STANDARD TABLE OF typ_film_out,
  gv_grid             TYPE REF TO cl_gui_alv_grid,
  "Req Management
  gt_request_out      TYPE STANDARD TABLE OF typ_request,
  "User Managment
  gt_usr_out          TYPE STANDARD TABLE OF typ_usr_out,

  "9320 Upload Files
  gv_file             TYPE rlgrap-filename,
  gt_excel            TYPE STANDARD TABLE OF zjkt_005_fminfo,

  "9330 Download Files
  gv_file_down        TYPE rlgrap-filename,
  gt_excel_down       TYPE STANDARD TABLE OF zjkt_005_fminfo,

  "9340 Ticket Information
  gt_ticinfo_out      TYPE STANDARD TABLE OF typ_ticket_1,

  "9520 Search Film
  gv_fmname           TYPE zjkt_005_fminfo-fmname,
*  gv_fdate            TYPE zjkt_005_fminfo-fdate,
*  gv_director         TYPE zjkt_005_fminfo-director,
*  gv_country          TYPE zjkt_005_fminfo-country,
*  gv_type             TYPE zjkt_005_fminfo-type,
*  gv_ldro_1           TYPE zjkt_005_fminfo-ldro_1,
*  gv_ldro_2           TYPE zjkt_005_fminfo-ldro_2,
*  gv_ldro_3           TYPE zjkt_005_fminfo-ldro_3,

  gr_container        TYPE REF TO cl_gui_custom_container,           "CONTAINER
  gr_table            TYPE REF TO cl_salv_table,                     "salv_table
  gr_functions        TYPE REF TO cl_salv_functions_list,            "get_function
  gr_display          TYPE REF TO cl_salv_display_settings,
  gr_columns          TYPE REF TO cl_salv_columns_table,             "GET_COLUMNS
  gt_search_out       TYPE STANDARD TABLE OF typ_film,

  "9530 Set Favourite Film
  gr_container_9530   TYPE REF TO cl_gui_custom_container,           "CONTAINER
  gr_table_9530       TYPE REF TO cl_salv_table,                     "salv_table
  gr_functions_9530   TYPE REF TO cl_salv_functions_list,            "get_function
  gr_display_9530     TYPE REF TO cl_salv_display_settings,
  gr_columns_9530     TYPE REF TO cl_salv_columns_table,             "GET_COLUMNS
  gt_fav_out          TYPE STANDARD TABLE OF typ_fav_out,

  "9540 Cinema Info
  gv_cine_1           TYPE zjkt_005_cinema-fmcine_1,
  gv_cine_2           TYPE zjkt_005_cinema-fmcine_2,
  gv_cine_3           TYPE zjkt_005_cinema-fmcine_3,
  gt_ticket_out_1     TYPE STANDARD TABLE OF typ_ticket_1,
  gv_cine             TYPE zjkt_005_cinema-fmcine_1,
  gv_price            TYPE zjkt_005_tickets-price.
