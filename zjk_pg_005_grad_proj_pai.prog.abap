*&---------------------------------------------------------------------*
*& Include          ZJK_PG_005_GRAD_PROJ_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000_EXIT  INPUT
*&---------------------------------------------------------------------*
*  User Command Exit
*----------------------------------------------------------------------*
MODULE user_command_9000_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*& User Command
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  gv_save_ok = ok_code.
  CASE ok_code.
    WHEN 'BTN1'.
      SET SCREEN 9100.
    WHEN 'BTN2'.
      SET SCREEN 9200.
    WHEN OTHERS.
      "Do Nothing.
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       User Command 9100 Exit
*----------------------------------------------------------------------*
MODULE user_command_9100_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9000.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_LOG_ON  INPUT
*&---------------------------------------------------------------------*
*      Get administrator name and password
*----------------------------------------------------------------------*
MODULE init_log_on INPUT.
  gv_ad_name = zjkt_005_admi-ad_name.
  gv_ad_password = zjkt_005_admi-ad_password.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       User Command 9100
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BTN1'.
      PERFORM frm_check_log_on.
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9200_EXIT  INPUT
*&---------------------------------------------------------------------*
*       User Command exit 9200
*----------------------------------------------------------------------*
MODULE user_command_9200_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9000.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_USR_LOG_ON  INPUT
*&---------------------------------------------------------------------*
*       Init For User Log On
*----------------------------------------------------------------------*
MODULE init_usr_log_on INPUT.
  gv_usr_name        = zjkt_005_user-ur_name.
  gv_usr_password    = zjkt_005_user-ur_password.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*       User Command 9200
*----------------------------------------------------------------------*
MODULE user_command_9200 INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BTN1'.                      "Log On
      PERFORM frm_usr_log_on.
    WHEN 'BTN2'.                      "Sign In
      SET SCREEN 9400.
    WHEN 'BTN3'.                      "Reset Password REQ.
      PERFORM frm_reset_req.
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9300_EXIT  INPUT
*&---------------------------------------------------------------------*
*       User Command 9300 Exit
*----------------------------------------------------------------------*
MODULE user_command_9300_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9100.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9300  INPUT
*&---------------------------------------------------------------------*
*       User Command 9300
*----------------------------------------------------------------------*
MODULE user_command_9300 INPUT.
  "Case BTN
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BTN1'.                    "Sign Out
      SET SCREEN 9000.
      LEAVE SCREEN.
    WHEN 'BTN2'.                    "User Mangement
      PERFORM frm_get_usr.
      PERFORM frm_disalv_usr.
    WHEN 'BTN3'.                    "Film Management
      PERFORM frm_get_filminfo.
      PERFORM frm_disalv.
    WHEN 'BTN4'.                    "Upload File
      PERFORM frm_upload.
    WHEN 'BTN5'.                    "Request Management
      PERFORM frm_get_req.
      PERFORM frm_disalv_req.
    WHEN 'BTN6'.                    "Download File
      PERFORM frm_get_filminfo.
      PERFORM frm_download.
    WHEN 'BTN7'.
      CLEAR gt_ticinfo_out.
      PERFORM frm_get_ticinfo.
      PERFORM frm_dis_ticinfo.
    WHEN OTHERS.
      tabstrip_film-activetab = gv_save_ok.
  ENDCASE.

  "Case TAB
  CASE tabstrip_film-activetab.
    WHEN 'TAB1'.
      gv_dynnr = '9310'.
    WHEN 'TAB2'.
      gv_dynnr = '9320'.
    WHEN 'TAB3'.
      gv_dynnr = '9330'.
    WHEN 'TAB4'.
      gv_dynnr = '9340'.
    WHEN OTHERS.
      "Do Nothing

  ENDCASE.
  CLEAR: gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9400_EXIT  INPUT
*&---------------------------------------------------------------------*
*       USER_COMMAND_EXIT 9400
*----------------------------------------------------------------------*
MODULE user_command_9400_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9200.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_SIGN_IN  INPUT
*&---------------------------------------------------------------------*
*       Init User Sign In Information
*----------------------------------------------------------------------*
MODULE init_sign_in INPUT.

  gv_usr_name        = zjkt_005_user-ur_name.
  gv_usr_password    = zjkt_005_user-ur_password.
  gv_usr_password_re = zjkt_005_user-ur_password_re.
  gv_usr_sex         = zjkt_005_user-sex.
  gv_usr_age         = zjkt_005_user-age.
  gv_usr_tel         = zjkt_005_user-tel.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9400  INPUT
*&---------------------------------------------------------------------*
*       User Command 9400
*----------------------------------------------------------------------*
MODULE user_command_9400 INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BTN1'.                      "Submit
      PERFORM frm_usr_sign_in.
    WHEN 'BTN2'.                      "Clear
      PERFORM frm_clear_usr_info.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9500_EXIT  INPUT
*&---------------------------------------------------------------------*
*       User Command 9500 Exit
*----------------------------------------------------------------------*
MODULE user_command_9500_exit INPUT.
  gv_save_ok = ok_code.
  CASE gv_save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 9200.
      LEAVE SCREEN.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
  CLEAR gv_save_ok.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9500  INPUT
*&---------------------------------------------------------------------*
*       User Command 9500
*----------------------------------------------------------------------*
MODULE user_command_9500 INPUT.
  gv_save_ok = ok_code.

  "Case BTN
  CASE gv_save_ok.
    WHEN 'BTN1'.                    "Save
      PERFORM frm_save_usr.
    WHEN 'BTN2'.                    "Clear
      PERFORM frm_clear_usr_info.
    WHEN 'BTN3'.                    "Get user Info
      PERFORM frm_get_usr_info.
    WHEN 'BTN4'.                    "Search Film
      CLEAR gt_search_out.
      PERFORM frm_search.
    WHEN 'BTN5'.                    "Add Favourite Film
      PERFORM frm_get_filminfo.
      PERFORM frm_dis_fm.
    WHEN 'BTN6'.                    "Display My Favourite
      CLEAR gt_fav_out.
      PERFORM frm_dis_fav.
    WHEN 'BTN7'.
      CLEAR zjkt_005_cinema.
      PERFORM frm_get_cine.         "Get Cinema
    WHEN 'BTN8'.                    "Remove User
      PERFORM frm_remove_req.
      SET SCREEN 9200.
    WHEN 'BTN9'.
      PERFORM frm_get_all.
    WHEN 'BTN10'.
      IF zjkt_005_cinema-fmcine_1 IS NOT INITIAL.
        CLEAR gt_ticket_out_1.
        PERFORM frm_get_price_1.
        PERFORM frm_get_ticket.
        PERFORM frm_dis_ticket.
      ELSE.
        MESSAGE i046 WITH gv_fmname. "The Film &1 is not shown on the screen.
      ENDIF.
    WHEN 'BTN11'.
      IF zjkt_005_cinema-fmcine_2 IS NOT INITIAL.
        PERFORM frm_get_price_2.
        PERFORM frm_get_ticket.
        PERFORM frm_dis_ticket.
      ELSE.
        MESSAGE i046 WITH gv_fmname. "The Film &1 is not shown on the screen.
      ENDIF.
    WHEN 'BTN12'.
      IF zjkt_005_cinema-fmcine_3 IS NOT INITIAL.
        PERFORM frm_get_price_3.
        PERFORM frm_get_ticket.
        PERFORM frm_dis_ticket.
      ELSE.
        MESSAGE i046 WITH gv_fmname. "The Film &1 is not shown on the screen.
      ENDIF.
    WHEN OTHERS.
      tabstrip_user-activetab = gv_save_ok.
  ENDCASE.

  "Case Tab
  CASE tabstrip_user-activetab.
    WHEN 'TAB1'.                "User Personal Info
      gv_dynnr = '9510'.
    WHEN 'TAB2'.                "Search Film
      gv_dynnr = '9520'.
    WHEN 'TAB3'.                "Set Favourite Film
      gv_dynnr = '9530'.
    WHEN 'TAB4'.                "Film Cinema
      gv_dynnr = '9540'.
    WHEN OTHERS.
  ENDCASE.
  CLEAR gv_save_ok.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_CHANGE_INFO  INPUT
*&---------------------------------------------------------------------*
*       Init Change Info
*----------------------------------------------------------------------*
MODULE init_change_info INPUT.
  gv_usr_name        = zjkt_005_user-ur_name.
  gv_usr_password    = zjkt_005_user-ur_password.
  gv_usr_password_re = zjkt_005_user-ur_password_re.
  gv_usr_sex         = zjkt_005_user-sex.
  gv_usr_age         = zjkt_005_user-age.
  gv_usr_tel         = zjkt_005_user-tel.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_FILE  INPUT
*&---------------------------------------------------------------------*
*       Search Help
*----------------------------------------------------------------------*
MODULE f4_file INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      mask             = '*.XLSX,*.*.'
      mode             = '0'
      title            = 'Upload File'
    IMPORTING
      filename         = gv_file
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_SEARCH  INPUT
*&---------------------------------------------------------------------*
*       Search Film
*----------------------------------------------------------------------*
MODULE init_search INPUT.
  gv_fmname   = zjkt_005_fminfo-fmname.
*  gv_fdate    = zjkt_005_fminfo-fdate.
*  gv_director = zjkt_005_fminfo-director.
*  gv_country  = zjkt_005_fminfo-country.
*  gv_type     = zjkt_005_fminfo-type.
*  gv_ldro_1   = zjkt_005_fminfo-ldro_1.
*  gv_ldro_2   = zjkt_005_fminfo-ldro_2.
*  gv_ldro_3   = zjkt_005_fminfo-ldro_3.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_CINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_cine INPUT.
  gv_fmname = zjkt_005_cinema-fmname.
  gv_cine_1 = zjkt_005_cinema-fmcine_1.
  gv_cine_2 = zjkt_005_cinema-fmcine_2.
  gv_cine_3 = zjkt_005_cinema-fmcine_3.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_DOWNLOAD  INPUT
*&---------------------------------------------------------------------*
*       Download Search Help
*----------------------------------------------------------------------*
MODULE f4_download INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      mask             = '*.XLSX,*.*.'
      mode             = 'S'
      title            = 'Download File'
    IMPORTING
      filename         = gv_file_down
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.
