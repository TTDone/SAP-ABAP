*&---------------------------------------------------------------------*
*& Include          ZJK_PG_005_GRAD_PROJ_FORMS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form FRM_PIC
*&---------------------------------------------------------------------*
*& Get & Set Picture
*&---------------------------------------------------------------------*
FORM frm_pic .
  " Add Picture For Title Page
  DATA:
    lv_graphic_xstr TYPE xstring,
    lv_graphic_conv TYPE i,
    lv_graphic_offs TYPE i.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object       = 'GRAPHICS'
      p_name         = 'TITLE PAGE'      "Pic Name in SE78
      p_id           = 'BMAP'
      p_btype        = 'BCOL'            "BMON = black&white, BCOL = colour
    RECEIVING
      p_bmp          = lv_graphic_xstr
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  gv_graphic_size = xstrlen( lv_graphic_xstr ).
  CHECK gv_graphic_size > 0.
  lv_graphic_conv = gv_graphic_size.
  lv_graphic_offs = 0.

  WHILE lv_graphic_conv > 255.
    gs_graphic-line = lv_graphic_xstr+lv_graphic_offs(255).
    APPEND gs_graphic TO gt_graphic.
    lv_graphic_offs = lv_graphic_offs + 255.
    lv_graphic_conv = lv_graphic_conv - 255.
  ENDWHILE.

  gs_graphic-line = lv_graphic_xstr+lv_graphic_offs(lv_graphic_conv).
  APPEND gs_graphic TO gt_graphic.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type                 = 'image'
      subtype              = cndp_sap_tab_unknown
      size                 = gv_graphic_size
*     DATE                 =
*     TIME                 =
*     DESCRIPTION          =
      lifetime             = cndp_lifetime_transaction
*     CACHEABLE            =
*     SEND_DATA_AS_STRING  =
*     FIELDS_FROM_APP      =
    TABLES
      data                 = gt_graphic
*     FIELDS               =
*     PROPERTIES           =
*     COLUMNS_TO_STRETCH   =
    CHANGING
      url                  = gv_graphic_url
    EXCEPTIONS
      dp_invalid_parameter = 1
      dp_error_put_table   = 2
      dp_error_general     = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CREATE OBJECT container
    EXPORTING
      container_name = 'CONTAINER'.
  CREATE OBJECT gv_pic
    EXPORTING
      parent = container.

  CALL METHOD gv_pic->load_picture_from_url
    EXPORTING
      url    = gv_graphic_url
    IMPORTING
      result = gv_result
    EXCEPTIONS
      error  = 1
      OTHERS = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL METHOD gv_pic->set_display_mode
    EXPORTING
      display_mode = cl_gui_picture=>adust_design_true "x Auto Set For The Size
    EXCEPTIONS
      error        = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_CHECK_LOG_IN
*&---------------------------------------------------------------------*
*& Check Log In Info.
*&---------------------------------------------------------------------*
FORM frm_check_log_on .
  IF gv_ad_name IS INITIAL
    OR gv_ad_password IS INITIAL.
    MESSAGE i030.                         "Please complete your entry.
  ELSE.
    SELECT
    ad_name,
    ad_password
    FROM zjkt_005_admi
    WHERE ad_name = @gv_ad_name
    AND ad_password = @gv_ad_password
    INTO TABLE @DATA(lt_log_in).
    IF sy-subrc = 0.
      MESSAGE s031 WITH gv_ad_name.      "Welcome, &1！
      SET SCREEN 9300.
    ELSE.
      SELECT SINGLE
        ad_name
        FROM zjkt_005_admi
        WHERE ad_name = @gv_ad_name
        INTO @DATA(ls_name).
      IF sy-subrc = 0.
        MESSAGE i032 WITH 'Password'.     "The &1 you input is wrong.
      ELSE.
        MESSAGE i015 WITH gv_ad_name.     "User &1 doesn't exist!
      ENDIF.
    ENDIF.
  ENDIF.
  FREE lt_log_in.
  CLEAR ls_name.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_USR_LOG_on
*&---------------------------------------------------------------------*
*& User Log On
*&---------------------------------------------------------------------*
FORM frm_usr_log_on .
  IF gv_usr_name IS INITIAL
    OR gv_usr_password IS INITIAL.
    MESSAGE i030.                       "Please complete your entry.
  ELSE.
    SELECT
      ur_name,
      ur_password
      FROM zjkt_005_user
      WHERE ur_name = @gv_usr_name
      AND ur_password = @gv_usr_password
      INTO TABLE @DATA(lt_usr_log_on).
    IF sy-subrc = 0.
      MESSAGE s031 WITH gv_usr_name.      "Welcome, &1！
      SET SCREEN 9500.
    ELSE.
      SELECT SINGLE
        ur_name
        FROM zjkt_005_user
        WHERE ur_name = @gv_usr_name
        INTO @DATA(ls_ur_name).
      IF sy-subrc = 0.
        MESSAGE i032 WITH 'Password'.     "The &1 you input is wrong.
      ELSE.
        MESSAGE i015 WITH gv_usr_name.    "User &1 doesn't exist!
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR ls_ur_name.
  FREE lt_usr_log_on.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_USR_SIGN_IN
*&---------------------------------------------------------------------*
*& User Sign In
*&---------------------------------------------------------------------*
FORM frm_usr_sign_in .
  DATA:
    ls_user TYPE zjkt_005_user.
  IF gv_usr_name IS INITIAL
    OR gv_usr_password IS INITIAL
    OR gv_usr_password_re IS INITIAL
    OR gv_usr_sex IS INITIAL
    OR gv_usr_age IS INITIAL
    OR gv_usr_tel IS INITIAL.
    MESSAGE i030.                       "Please complete your entry.
  ELSE.
    SELECT
      ur_name,
      ur_password,
      ur_password_re,
      sex,
      age,
      tel
      FROM zjkt_005_user
      WHERE ur_name = @gv_usr_name
      INTO TABLE @DATA(lt_user).
    IF sy-subrc = 0.
      MESSAGE i033 WITH gv_usr_name.        "User &1 already exits
    ELSEIF gv_usr_password = gv_usr_password_re AND gv_usr_password IS NOT INITIAL.
      ls_user-ur_name = gv_usr_name.
      ls_user-ur_password = gv_usr_password.
      ls_user-ur_password_re = gv_usr_password_re.
      ls_user-sex = gv_usr_sex.
      ls_user-age = gv_usr_age.
      ls_user-tel = gv_usr_tel.
      INSERT zjkt_005_user FROM ls_user.
      IF sy-subrc = 0.
        MESSAGE s035 WITH gv_usr_name.      "User &1 Created Sucessfully.
      ELSE.
        MESSAGE i019.                       "There Is An Error Occoured.
      ENDIF.
    ELSE.
      MESSAGE i034.                         "Please Input The Same Password.
    ENDIF.
  ENDIF.

  FREE lt_user.
  CLEAR ls_user.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_CLEAR_USR_INFO
*&---------------------------------------------------------------------*
*& Clear Usr's Info.
*&---------------------------------------------------------------------*
FORM frm_clear_usr_info .
  CLEAR zjkt_005_user.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_FILMINFO
*&---------------------------------------------------------------------*
*& Get Film Information
*&---------------------------------------------------------------------*
FORM frm_get_filminfo .

  SELECT
  fmname,
  fdate,
  director,
  country,
  type,
  ldro_1,
  ldro_2,
  ldro_3
  FROM zjkt_005_fminfo
  INTO TABLE @DATA(lt_film).
  IF sy-subrc = 0
    AND gt_film_out IS INITIAL.
    gt_film_out = VALUE #( BASE gt_film_out
                       FOR ls_film IN lt_film
                       ( fmname = ls_film-fmname
                         fdate = ls_film-fdate
                         director = ls_film-director
                         country = ls_film-country
                         type = ls_film-type
                         ldro_1 = ls_film-ldro_1
                         ldro_2 = ls_film-ldro_2
                         ldro_3 = ls_film-ldro_3 ) ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DISALV
*&---------------------------------------------------------------------*
*& Display ALV
*&---------------------------------------------------------------------*
FORM frm_disalv .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  gt_film_copy         = gt_film_out.
  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'Film Infomation'.
  ls_layout-box_fname  = 'SEL'.

  "DEFINE MACRO
  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-edit      = &5.   "ALV control: Ready for input
    ls_fieldcat-emphasize = &6.   "ALV control: Highlight column with color
    ls_fieldcat-lowercase = &7.   "Lowercase letters allowed/not allowed
    ls_fieldcat-intlen    = &8.   "Internal Length in Bytes
    ls_fieldcat-col_opt   = &9.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1             &2            &3  &4  &5    &6       &7  &8    &9
  macro_fill_fdcat 'FMNAME'   'Film Name'       'X' 'R' ''    ''       ''  ''    'x'.
  macro_fill_fdcat 'FDATE'    'Release Date'    ''  'L' ''    'C300'   ''  ''    'x'.
  macro_fill_fdcat 'DIRECTOR' 'Director'        ''  'L' 'X'   ''       'X' '88'  'x'.
  macro_fill_fdcat 'COUNTRY'  'Country'         ''  'L' 'X'   ''       ''  ''    'x'.
  macro_fill_fdcat 'TYPE'     'Film Type'       ''  'L' 'X'   ''       ''  ''    'x'.
  macro_fill_fdcat 'LDRO_1'   'Lead Role 1'     ''  'L' 'X'   ''       ''  ''    'x'.
  macro_fill_fdcat 'LDRO_2'   'Lead Role 2'     ''  'L' 'X'   ''       ''  ''    'x'.
  macro_fill_fdcat 'LDRO_3'   'Lead Role 3'     ''  'L' 'X'   ''       ''  ''    'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          =
*     I_BUFFER_ACTIVE             =
      i_callback_program          = lv_repid
      i_callback_pf_status_set    = 'SET_PF_STATUS'
      i_callback_user_command     = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE      = ' '
      i_callback_html_top_of_page = 'TOP_OF_PAGE_HTML'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
      is_layout_lvc               = ls_layout
      it_fieldcat_lvc             = lt_fieldcat
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS_LVC       =
*     IT_SORT_LVC                 =
*     IT_FILTER_LVC               =
*     IT_HYPERLINK                =
*     IS_SEL_HIDE                 =
*     I_DEFAULT                   = 'X'
      i_save                      = 'X'
*     IS_VARIANT                  =
*     IT_EVENTS                   =
*     IT_EVENT_EXIT               =
*     IS_PRINT_LVC                =
*     IS_REPREP_ID_LVC            =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     I_HTML_HEIGHT_TOP           =
*     I_HTML_HEIGHT_END           =
*     IT_ALV_GRAPHICS             =
*     IT_EXCEPT_QINFO_LVC         =
*     IR_SALV_FULLSCREEN_ADAPTER  =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      t_outtab                    = gt_film_out
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0.
    MESSAGE e007.         "WARNING!!THE INFORMATION YOU TAP IS WRONG!!
  ENDIF.

  FREE: lt_fieldcat, ls_fieldcat, ls_layout.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_PF_STATUS
*&---------------------------------------------------------------------*
*& SET_PF_STATUS
*&---------------------------------------------------------------------*
*&      --> RT_EXTAB
*&---------------------------------------------------------------------*
FORM set_pf_status  USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_USR_LIST'." EXCLUDING rt_extab.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
*& USER_COMMAND
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command  USING r_ucomm     TYPE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.


  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*   EXPORTING
*     IR_SALV_FULLSCREEN_ADAPTER       =
    IMPORTING
      e_grid = lr_grid.
  "Verification of Changes and Triggering of Event DATA_CHANGED
  CALL METHOD lr_grid->check_changed_data.

  rs_selfield-refresh = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  CASE lv_save_ok.
    WHEN '&DATA_SAVE'.
      PERFORM frm_film_edit.
    WHEN 'DELETE'.
      PERFORM frm_delete_film.
      rs_selfield-refresh = abap_true.      "Refresh
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR: lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_FILM_EDIT
*&---------------------------------------------------------------------*
*& Film Info. Edit
*&---------------------------------------------------------------------*
FORM frm_film_edit .
  DATA:
    ls_film_out  TYPE typ_film_out,
    ls_film_edit TYPE zjkt_005_fminfo,
    lt_film_out  TYPE STANDARD TABLE OF zjkt_005_fminfo.

  LOOP AT gt_film_out INTO ls_film_out.
    MOVE-CORRESPONDING ls_film_out TO ls_film_edit.
    SELECT SINGLE
      mandt
      FROM zjkt_005_fminfo
      INTO @DATA(lv_mandt).
    ls_film_edit-mandt = lv_mandt.
    APPEND ls_film_edit TO lt_film_out.
    CLEAR:ls_film_out,lv_mandt.
  ENDLOOP.

  UPDATE zjkt_005_fminfo FROM TABLE lt_film_out.
  IF sy-subrc = 0.
    MESSAGE s036.         "Data has been saved successfully.
  ELSE.
    MESSAGE i030.         "Please complete your entry.
  ENDIF.

  FREE lt_film_out.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_USR_INFO
*&---------------------------------------------------------------------*
*& Get User Personal Info.
*&---------------------------------------------------------------------*
FORM frm_get_usr_info .
  SELECT SINGLE
    ur_name,
    ur_password,
    ur_password_re,
    sex,
    age,
    tel
    FROM zjkt_005_user
    WHERE ur_name = @gv_usr_name
    INTO @DATA(ls_user).
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_user TO zjkt_005_user.
  ENDIF.
  CLEAR ls_user.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_SAVE_USR
*&---------------------------------------------------------------------*
*& Save User Personal Info
*&---------------------------------------------------------------------*
FORM frm_save_usr .
  DATA:
        ls_user TYPE zjkt_005_user.
  IF gv_usr_name IS INITIAL
   OR gv_usr_password IS INITIAL
   OR gv_usr_password_re IS INITIAL
   OR gv_usr_sex IS INITIAL
   OR gv_usr_age IS INITIAL
   OR gv_usr_tel IS INITIAL.
    MESSAGE i030.                           "Please complete your entry.
  ELSE.
*    SELECT SINGLE
*      ur_name
*      FROM zjkt_005_user
*      WHERE ur_name = @gv_usr_name
*      INTO @DATA(lv_name).
*    IF sy-subrc = 0.
*      MESSAGE i033 WITH gv_usr_name.        "User &1 already exits
    IF gv_usr_password = gv_usr_password_re AND gv_usr_password IS NOT INITIAL.
      ls_user-ur_name = gv_usr_name.
      ls_user-ur_password = gv_usr_password.
      ls_user-ur_password_re = gv_usr_password_re.
      ls_user-sex = gv_usr_sex.
      ls_user-age = gv_usr_age.
      ls_user-tel = gv_usr_tel.
      UPDATE zjkt_005_user FROM ls_user.
      IF sy-subrc = 0.
        MESSAGE i036.                       "Data has been saved successfully.
      ELSE.
        MESSAGE i019.                       "There Is An Error Occoured.
      ENDIF.
    ELSE.
      MESSAGE i034.                         "Please Input The Same Password.
    ENDIF.
  ENDIF.

  CLEAR: ls_user.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_USR
*&---------------------------------------------------------------------*
*& Get User Info.
*&---------------------------------------------------------------------*
FORM frm_get_usr .

  SELECT
    ur_name,
    ur_password,
    sex,
    age,
    tel
    FROM zjkt_005_user
    INTO TABLE @DATA(lt_usr_out).
  IF sy-subrc = 0
  AND gt_usr_out IS INITIAL.
    gt_usr_out = VALUE #( BASE gt_usr_out
                       FOR ls_usr_out IN lt_usr_out
                       ( ur_name = ls_usr_out-ur_name
                         ur_password = ls_usr_out-ur_password
                         sex = ls_usr_out-sex
                         age = ls_usr_out-age
                         tel = ls_usr_out-tel ) ).
  ENDIF.
  FREE lt_usr_out.
ENDFORM.
*&age,---------------------------------------------------------------------*
*&tel Form FRM_DISALV_USR
*&---------------------------------------------------------------------*
*& Set & Display alv for User
*&---------------------------------------------------------------------*
FORM frm_disalv_usr .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'User Management'.   "Set Title
  ls_layout-box_fname  = 'SEL'.

  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-edit      = &5.   "ALV control: Ready for input
    ls_fieldcat-emphasize = &6.   "ALV control: Highlight column with color
    ls_fieldcat-lowercase = &7.   "Lowercase letters allowed/not allowed
    ls_fieldcat-intlen    = &8.   "Internal Length in Bytes
    ls_fieldcat-col_opt   = &9.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1             &2            &3  &4  &5    &6       &7  &8    &9
  macro_fill_fdcat 'UR_NAME'      'User Name'   'X' 'R' ''   ''       ''  ''    'x'.
  macro_fill_fdcat 'UR_PASSWORD'  'Password'    ''  'L' 'X'  ''       ''  ''    'x'.
  macro_fill_fdcat 'SEX'          'Sex'         ''  'L' ''   'C300'   'X' '88'  'x'.
  macro_fill_fdcat 'AGE'          'Age'         ''  'L' ''   ''       ''  ''    'x'.
  macro_fill_fdcat 'TEL'          'Telephone'   ''  'L' ''   ''       ''  ''    'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = lv_repid
      i_callback_pf_status_set = 'SET_USR_STATUS'
      i_callback_user_command  = 'USER_COMMAND_USR'
      i_grid_title             = 'User List'
      is_layout_lvc            = ls_layout
      it_fieldcat_lvc          = lt_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_usr_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  FREE: lt_fieldcat, ls_fieldcat, ls_layout.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_USR_STATUS
*&---------------------------------------------------------------------*
*& SET_USR_STATUS
*&---------------------------------------------------------------------*
*&      --> RT_EXTAB
*&---------------------------------------------------------------------*
FORM set_usr_status  USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_USR_LIST'." EXCLUDING rt_extab.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_USR
*&---------------------------------------------------------------------*
*& USER_COMMAND_USR
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command_usr  USING r_ucomm     TYPE sy-ucomm
                             rs_selfield TYPE slis_selfield.
  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.

  CASE lv_save_ok.
    WHEN '&DATA_SAVE'.
      PERFORM frm_usr_mod.
    WHEN 'DELETE'.
      PERFORM frm_usr_delete.
      rs_selfield-refresh = abap_true.      "Refresh
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR:lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_USR_DELETE
*&---------------------------------------------------------------------*
*& Delete User
*&---------------------------------------------------------------------*
FORM frm_usr_delete .
  DATA:
    ls_usr_delete TYPE zjkt_005_user,
    lt_usr_delete TYPE STANDARD TABLE OF zjkt_005_user.

  LOOP AT gt_usr_out INTO DATA(ls_usr_out)
    WHERE ( sel = abap_true ).
    MOVE-CORRESPONDING ls_usr_out TO ls_usr_delete.
    APPEND ls_usr_delete TO lt_usr_delete.
  ENDLOOP.

  IF lt_usr_delete IS INITIAL.
    MESSAGE i038.             "Please select an entry.
  ELSE.
    DELETE zjkt_005_user FROM TABLE lt_usr_delete.
    IF sy-subrc = 0.
      MESSAGE s037.           "User Deleted Successfully.
    ENDIF.
  ENDIF.

  FREE gt_usr_out.
  PERFORM frm_get_usr.        "Refresh gt_usr_out

  CLEAR :ls_usr_delete,ls_usr_out.
  FREE lt_usr_delete.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_UPLOAD
*&---------------------------------------------------------------------*
*& Upload a file
*&---------------------------------------------------------------------*
FORM frm_upload .
  DATA:
        i_raw TYPE truxs_t_text_data.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = 'X'        "Upload with no header
      i_tab_raw_data       = i_raw
      i_filename           = gv_file
    TABLES
      i_tab_converted_data = gt_excel
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE i019.                        "There Is An Error Occured.
  ELSE.
    PERFORM frm_save_file.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_SEARCH
*&---------------------------------------------------------------------*
*& Saearch Film
*&---------------------------------------------------------------------*
FORM frm_search .
  IF gv_fmname IS NOT INITIAL.
    SELECT SINGLE
      fmname,
      fdate,
      director,
      country,
      type,
      ldro_1,
      ldro_2,
      ldro_3
    FROM zjkt_005_fminfo
    WHERE fmname = @gv_fmname
    INTO @DATA(ls_fname).
    IF sy-subrc = 0.
      APPEND ls_fname TO gt_search_out.
    ELSE.
      MESSAGE i039 WITH gv_fmname.     "There is no such a film called &1.
    ENDIF.
  ELSE.
    MESSAGE i041.                      "Please input the name of the film.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_ADD_FAV
*&---------------------------------------------------------------------*
*& Add Favourite Film
*&---------------------------------------------------------------------*
FORM frm_dis_fm .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  gt_film_copy         = gt_film_out.
  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'Add Your Favourite'.
  ls_layout-box_fname  = 'SEL'.

  "DEFINE MACRO
  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-col_opt   = &5.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1             &2            &3  &4   &5
  macro_fill_fdcat 'FMNAME'   'Film Name'       'X' 'R'  'x'.
  macro_fill_fdcat 'FDATE'    'Release Date'    ''  'L'  'x'.
  macro_fill_fdcat 'DIRECTOR' 'Director'        ''  'L'  'x'.
  macro_fill_fdcat 'COUNTRY'  'Country'         ''  'L'  'x'.
  macro_fill_fdcat 'TYPE'     'Film Type'       ''  'L'  'x'.
  macro_fill_fdcat 'LDRO_1'   'Lead Role 1'     ''  'L'  'x'.
  macro_fill_fdcat 'LDRO_2'   'Lead Role 2'     ''  'L'  'x'.
  macro_fill_fdcat 'LDRO_3'   'Lead Role 3'     ''  'L'  'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = lv_repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND_FV'
      is_layout_lvc            = ls_layout
      it_fieldcat_lvc          = lt_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_film_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e007.         "WARNING!!THE INFORMATION YOU TAP IS WRONG!!
  ENDIF.

  FREE: lt_fieldcat, ls_fieldcat, ls_layout.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_USR
*&---------------------------------------------------------------------*
*& USER_COMMAND_fv
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command_fv  USING r_ucomm     TYPE sy-ucomm
                             rs_selfield TYPE slis_selfield.
  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.

  CASE lv_save_ok.
    WHEN '&DATA_SAVE'.
      PERFORM frm_add_fv.
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR:lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_ADD_FV
*&---------------------------------------------------------------------*
*& Add Film Into Favourite List
*&---------------------------------------------------------------------*
FORM frm_add_fv .
  DATA:
    ls_fv_out TYPE zjkt_005_favfm,
    lv_fmname TYPE zjkt_005_favfm-fmname.
  LOOP AT gt_film_out INTO DATA(ls_film_out)
    WHERE ( sel = abap_true ).
    ls_fv_out-ur_name = gv_usr_name.
    ls_fv_out-fmname = ls_film_out-fmname.
    lv_fmname = ls_film_out-fmname.

    SELECT SINGLE
      fmname,
      ur_name
      FROM zjkt_005_favfm
      WHERE ur_name = @gv_usr_name
      AND fmname = @lv_fmname
      INTO @DATA(ls_check).
    IF sy-subrc = 0.
      MESSAGE i042 WITH lv_fmname.        "Flim &1 already exists in your favourite list.
    ELSE.
      UPDATE zjkt_005_favfm FROM ls_fv_out.
      IF sy-subrc = 0.
        MESSAGE s036.                     "Data has been saved successfully.
      ENDIF.
    ENDIF.

  ENDLOOP.
  CLEAR:ls_fv_out,ls_film_out,lv_fmname,ls_check.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DIS_FAV
*&---------------------------------------------------------------------*
*& Display Favourite Film
*&---------------------------------------------------------------------*
FORM frm_dis_fav .
  SELECT
    fm~fmname,
    fm~fdate,
    fm~director,
    fm~country,
    fm~type,
    fm~ldro_1,
    fm~ldro_2,
    fm~ldro_3,
    fv~ur_name
   FROM zjkt_005_fminfo AS fm
   INNER JOIN zjkt_005_favfm AS fv
   ON fm~fmname = fv~fmname
   WHERE fv~ur_name = @gv_usr_name
   INTO TABLE @DATA(lt_fvfm).
  IF sy-subrc = 0.
    MOVE-CORRESPONDING lt_fvfm TO gt_fav_out.
  ENDIF.

  FREE lt_fvfm.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_SAVE_FILE
*&---------------------------------------------------------------------*
*& Save File
*&---------------------------------------------------------------------*
FORM frm_save_file .
  DATA:
    ls_upload TYPE zjkt_005_fminfo,
    lt_upload TYPE STANDARD TABLE OF zjkt_005_fminfo.
  LOOP AT gt_excel INTO DATA(ls_excel).
    MOVE-CORRESPONDING ls_excel TO ls_upload.
    APPEND ls_upload TO lt_upload.
  ENDLOOP.
  MODIFY zjkt_005_fminfo FROM TABLE lt_upload.
  IF sy-subrc = 0.
    MESSAGE s036.       "Data has been saved successfully.
  ENDIF.
  CLEAR: ls_upload,ls_excel.
  FREE lt_upload.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_LIST
*&---------------------------------------------------------------------*
*& Get User Request
*&---------------------------------------------------------------------*
FORM frm_get_req .
  SELECT
    ur_name,
    sta_reset,
    sta_remove
    FROM zjkt_005_req
    INTO TABLE @DATA(lt_request).
  IF sy-subrc = 0
    AND gt_request_out IS INITIAL.
    gt_request_out = VALUE #( BASE gt_request_out
                       FOR ls_request IN lt_request
                       ( ur_name = ls_request-ur_name
                         sta_reset = ls_request-sta_reset
                         sta_remove = ls_request-sta_remove ) ).
  ENDIF.
  FREE lt_request.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DISALV_REQ
*&---------------------------------------------------------------------*
*& Display ALV for request
*&---------------------------------------------------------------------*
FORM frm_disalv_req .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'User Request'.
  ls_layout-box_fname  = 'SEL'.

  "DEFINE MACRO
  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-col_opt   = &5.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1             &2            &3  &4   &5
  macro_fill_fdcat 'UR_NAME'      'User Name'   'X' 'R'  'x'.
  macro_fill_fdcat 'STA_RESET'    'Reset Psw.'  ''  'L'  'x'.
  macro_fill_fdcat 'STA_REMOVE'   'Remove User' ''  'L'  'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = lv_repid
      i_callback_pf_status_set = 'SET_USR_STATUS'
      i_callback_user_command  = 'USER_COMMAND_REQ'
      is_layout_lvc            = ls_layout
      it_fieldcat_lvc          = lt_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_request_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e007.         "WARNING!!THE INFORMATION YOU TAP IS WRONG!!
  ENDIF.

  FREE: lt_fieldcat, ls_fieldcat, ls_layout.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_REQ
*&---------------------------------------------------------------------*
*& USER_COMMAND_REQ
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command_req  USING r_ucomm     TYPE sy-ucomm
                             rs_selfield TYPE slis_selfield.
  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.

  CASE lv_save_ok.
    WHEN 'DELETE'.
      PERFORM frm_req_delete.
      rs_selfield-refresh = abap_true.      "Refresh
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR:lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_CINE
*&---------------------------------------------------------------------*
*& Get Cinema
*&---------------------------------------------------------------------*
FORM frm_get_cine .
  SELECT SINGLE
  fmname,
  fmcine_1,
  fmcine_2,
  fmcine_3
  FROM zjkt_005_cinema
    WHERE fmname = @gv_fmname
    INTO @DATA(ls_cine).
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_cine TO zjkt_005_cinema.
    MESSAGE s043.                   "Here are the cinemas that you could go
  ELSE.
    MESSAGE i046 WITH gv_fmname.    "The Film &1 is not shown on the screen.
  ENDIF.
  CLEAR ls_cine.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_RESET_REQ
*&---------------------------------------------------------------------*
*& User Reset PSW request
*&---------------------------------------------------------------------*
FORM frm_reset_req .
  DATA:
    lv_reset_req TYPE zjkt_005_req.
  IF gv_usr_name IS NOT INITIAL.
    SELECT SINGLE
      ur_name
      FROM zjkt_005_user
      WHERE ur_name = @gv_usr_name
      INTO @DATA(lv_name).
    IF sy-subrc = 0.
      lv_reset_req-ur_name = gv_usr_name.
      lv_reset_req-sta_reset = 'X'.
      INSERT zjkt_005_req FROM lv_reset_req.
      IF sy-subrc = 0.
        MESSAGE s044.                     "Your request has been submitted,please wait for approval.
      ENDIF.
    ELSE.
      MESSAGE i015 WITH gv_usr_name.      "USER XXX doesn't exit.
    ENDIF.
  ELSE.
    MESSAGE i030.                         "Please complete your entry.
  ENDIF.
  CLEAR: lv_reset_req,lv_name.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_USR_MOD
*&---------------------------------------------------------------------*
*& Modfiy User Info.
*&---------------------------------------------------------------------*
FORM frm_usr_mod .
  DATA:
    ls_usr_out  TYPE typ_usr_out,
    ls_usr_edit TYPE zjkt_005_user,
    lt_usr_out  TYPE STANDARD TABLE OF zjkt_005_user.

  LOOP AT gt_usr_out INTO ls_usr_out.
    MOVE-CORRESPONDING ls_usr_out TO ls_usr_edit.
    SELECT SINGLE
      mandt
      FROM zjkt_005_user
      INTO @DATA(lv_mandt).
    ls_usr_edit-mandt = lv_mandt.
    APPEND ls_usr_edit TO lt_usr_out.
    CLEAR:ls_usr_out,lv_mandt.
  ENDLOOP.

  UPDATE zjkt_005_user FROM TABLE lt_usr_out.
  IF sy-subrc = 0.
    MESSAGE s036.         "Data has been saved successfully.
  ELSE.
    MESSAGE i019.         "There Is An Error Occured.
  ENDIF.

  FREE lt_usr_out.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_REQ_DELETE
*&---------------------------------------------------------------------*
*& Delete Request
*&---------------------------------------------------------------------*
FORM frm_req_delete .
  DATA:
    ls_req_delete TYPE zjkt_005_req,
    lt_req_delete TYPE STANDARD TABLE OF zjkt_005_req.

  LOOP AT gt_request_out INTO DATA(ls_request_out)
    WHERE ( sel = abap_true ).
    MOVE-CORRESPONDING ls_request_out TO ls_req_delete.
    APPEND ls_req_delete TO lt_req_delete.
  ENDLOOP.

  IF lt_req_delete IS INITIAL.
    MESSAGE i037.             "Please select an entry.
  ELSE.
    DELETE zjkt_005_req FROM TABLE lt_req_delete.
    IF sy-subrc = 0.
      MESSAGE s037.           "User Deleted Successfully.
    ENDIF.
  ENDIF.

  FREE gt_request_out.
  PERFORM frm_get_req.        "Refresh gt_request_out

  CLEAR :ls_req_delete,ls_request_out.
  FREE lt_req_delete.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_REMOVE_REQ
*&---------------------------------------------------------------------*
*& Remove Request
*&---------------------------------------------------------------------*
FORM frm_remove_req .
  DATA:
    lv_remove_req TYPE zjkt_005_req.
  lv_remove_req-ur_name = gv_usr_name.
  lv_remove_req-sta_remove = 'X'.
  INSERT zjkt_005_req FROM lv_remove_req.
  IF sy-subrc = 0.
    MESSAGE s044.                     "Your request has been submitted,please wait for approval.
  ELSE.
    MESSAGE i007.
  ENDIF.
  CLEAR:lv_remove_req.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DOWNLOAD
*&---------------------------------------------------------------------*
*& Download File
*&---------------------------------------------------------------------*
FORM frm_download .

  CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
    EXPORTING
      i_filename        = gv_file_down
    TABLES
      i_tab_sap_data    = gt_film_out
    EXCEPTIONS
      conversion_failed = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE i019.         "There Is An Error Occured.
  ELSE.
    MESSAGE s016.         "Data Saved successfully!
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_ALL
*&---------------------------------------------------------------------*
*& Get all movie
*&---------------------------------------------------------------------*
FORM frm_get_all .
  SELECT
    fm~fmname,
    fm~fdate,
    fm~director,
    fm~country,
    fm~type,
    fm~ldro_1,
    fm~ldro_2,
    fm~ldro_3,
    fv~ur_name
   FROM zjkt_005_fminfo AS fm
   INNER JOIN zjkt_005_favfm AS fv
   ON fm~fmname = fv~fmname
   INTO TABLE @DATA(lt_fvfm).
  IF sy-subrc = 0.
    MOVE-CORRESPONDING lt_fvfm TO gt_search_out.
  ENDIF.

  FREE lt_fvfm.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DELETE_FILM
*&---------------------------------------------------------------------*
*& Delete Film
*&---------------------------------------------------------------------*
FORM frm_delete_film .
  DATA:
    ls_film_delete TYPE zjkt_005_fminfo,
    lt_film_delete TYPE STANDARD TABLE OF zjkt_005_fminfo.

  LOOP AT gt_film_out INTO DATA(ls_film_out)
    WHERE ( sel = abap_true ).
    MOVE-CORRESPONDING ls_film_out TO ls_film_delete.
    APPEND ls_film_delete TO lt_film_delete.
  ENDLOOP.

  IF lt_film_delete IS INITIAL.
    MESSAGE i037.             "Please select an entry.
  ELSE.
    DELETE zjkt_005_fminfo FROM TABLE lt_film_delete.
    IF sy-subrc = 0.
      MESSAGE s045.           "Film Deleted Successfully.
    ELSE.
      MESSAGE i019.           "There Is An Error Occured.
    ENDIF.
  ENDIF.

  FREE gt_film_out.
  PERFORM frm_get_filminfo.   "Refresh gt_film_out

  CLEAR :ls_film_delete,ls_film_out.
  FREE lt_film_delete.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_TICKET_1
*&---------------------------------------------------------------------*
*& Get Tiecket Information 1st
*&---------------------------------------------------------------------*
FORM frm_get_ticket .
  DATA:
    ls_tic TYPE zjkt_005_tickets,
    lt_tic TYPE STANDARD TABLE OF zjkt_005_tickets.

  ls_tic-ur_name = gv_usr_name.
  ls_tic-fmname = gv_fmname.
  ls_tic-fmcine = gv_cine.
  ls_tic-price = gv_price.
*  SELECT SINGLE
*    fmname,
*    fmcine_1,
*    price_1
*    FROM zjkt_005_cinema
*    WHERE fmname = @gv_fmname
*    INTO @DATA(ls_price).
*  IF sy-subrc = 0.
*    ls_tic-fmcine = ls_price-fmcine_1.
*    ls_tic-price = ls_price-price_1.
*  ENDIF.
  ls_tic-tic_date = sy-datum.
  ls_tic-tic_status = '待付款'.
  APPEND ls_tic TO lt_tic.

  SELECT SINGLE
    ur_name,
    tic_status
    FROM zjkt_005_tickets
    WHERE ur_name = @gv_usr_name
    INTO @DATA(ls_check).
  IF sy-subrc = 0.
    IF ls_check-tic_status = '待出票'.
      MESSAGE i047.   "You have already bought a tiecket, please check your order status.
    ELSE.
      DELETE zjkt_005_tickets FROM TABLE lt_tic.
      INSERT zjkt_005_tickets FROM TABLE lt_tic.
    ENDIF.
  ELSE.
    INSERT zjkt_005_tickets FROM TABLE lt_tic.
  ENDIF.


  SELECT
  ur_name,
  fmname,
  fmcine,
  price,
  tic_date,
  tic_status
  FROM zjkt_005_tickets
  WHERE ur_name = @gv_usr_name
  INTO TABLE @DATA(lt_ticket).
  IF sy-subrc = 0
    AND gt_ticket_out_1 IS INITIAL.
    gt_ticket_out_1 = VALUE #( BASE gt_ticket_out_1
                       FOR ls_ticket IN lt_ticket
                       ( ur_name = ls_ticket-ur_name
                         fmname = ls_ticket-fmname
                         fmcine = ls_ticket-fmcine
                         price = ls_ticket-price
                         tic_date = ls_ticket-tic_date
                         tic_status = ls_ticket-tic_status ) ).
  ENDIF.
  CLEAR: ls_tic,ls_check.
  FREE: lt_tic.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DIS_TICKET_1
*&---------------------------------------------------------------------*
*& Dis Tiecket Information 1st
*&---------------------------------------------------------------------*
FORM frm_dis_ticket .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'Buy Your Ticket'.
  ls_layout-box_fname  = 'SEL'.

  "DEFINE MACRO
  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-col_opt   = &5.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1                 &2              &3  &4   &5
  macro_fill_fdcat 'UR_NAME'      'User Name'         'X' 'R'  'x'.
  macro_fill_fdcat 'FMNAME'       'Film Name'         ''  'L'  'x'.
  macro_fill_fdcat 'FMCINE'       'Cinma'             ''  'L'  'x'.
  macro_fill_fdcat 'PRICE'        'Price'             ''  'L'  'x'.
  macro_fill_fdcat 'TIC_DATE'     'Purchase Date'     ''  'L'  'x'.
  macro_fill_fdcat 'TIC_STATUS'   'Purchase Status'   ''  'L'  'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = lv_repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND_TIC1'
      is_layout_lvc            = ls_layout
      it_fieldcat_lvc          = lt_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_ticket_out_1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e007.         "WARNING!!THE INFORMATION YOU TAP IS WRONG!!
  ENDIF.

  FREE: lt_fieldcat, ls_fieldcat, ls_layout.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_REQ
*&---------------------------------------------------------------------*
*& USER_COMMAND_TIC1
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command_tic1 USING r_ucomm     TYPE sy-ucomm
                             rs_selfield TYPE slis_selfield.
  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.

  CASE lv_save_ok.
    WHEN '&DATA_SAVE'.
      PERFORM frm_ticsave_1.
      rs_selfield-refresh = abap_true.      "Refresh
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR:lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_TICSAVE_1
*&---------------------------------------------------------------------*
*& Ticket Save
*&---------------------------------------------------------------------*
FORM frm_ticsave_1 .
  DATA:
    ls_ticket TYPE zjkt_005_tickets.
  LOOP AT gt_ticket_out_1 INTO DATA(ls_ticket_out_1)
      WHERE ( sel = abap_true ).
    ls_ticket_out_1-tic_status = '待出票'.
    MOVE-CORRESPONDING ls_ticket_out_1 TO ls_ticket.
    MODIFY gt_ticket_out_1 FROM ls_ticket_out_1.
    UPDATE zjkt_005_tickets FROM ls_ticket.
    IF sy-subrc = 0.
      MESSAGE s036.         "Data has been saved successfully.
    ENDIF.
  ENDLOOP.
  CLEAR: ls_ticket,ls_ticket_out_1.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_TICINFO
*&---------------------------------------------------------------------*
*& Get Ticket Infos
*&---------------------------------------------------------------------*
FORM frm_get_ticinfo .
  SELECT
   ur_name,
   fmname,
   fmcine,
   price,
   tic_date,
   tic_status
   FROM zjkt_005_tickets
   INTO TABLE @DATA(lt_ticket).
  IF sy-subrc = 0
    AND gt_ticinfo_out IS INITIAL.
    gt_ticinfo_out = VALUE #( BASE gt_ticinfo_out
                       FOR ls_ticket IN lt_ticket
                       ( ur_name = ls_ticket-ur_name
                         fmname = ls_ticket-fmname
                         fmcine = ls_ticket-fmcine
                         price = ls_ticket-price
                         tic_date = ls_ticket-tic_date
                         tic_status = ls_ticket-tic_status ) ).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_DIS_TICINFO
*&---------------------------------------------------------------------*
*& Display Ticket Info
*&---------------------------------------------------------------------*
FORM frm_dis_ticinfo .
  DATA:
    lv_repid    TYPE repid,
    lt_fieldcat TYPE lvc_t_fcat,
    ls_fieldcat TYPE lvc_s_fcat,
    ls_layout   TYPE lvc_s_layo.

  lv_repid             = sy-repid.
  ls_layout-zebra      = abap_true.           "striped pattern
  ls_layout-cwidth_opt = abap_true.           "ALV control: Optimize column width
  ls_layout-grid_title = 'Buy Your Ticket'.
  ls_layout-box_fname  = 'SEL'.

  "DEFINE MACRO
  DEFINE macro_fill_fdcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = &1.   "ALV control: Field name of internal table field
    ls_fieldcat-reptext   = &2.   "LVC tab name
    ls_fieldcat-key       = &3.   "ALV control: Key field
    ls_fieldcat-just      = &4.   "ALV control: Alignment (R)ight (L)eft (C)ent.
    ls_fieldcat-col_opt   = &5.   "Entry for Optional Column Optimization
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  "SET MACRO       &1                 &2              &3  &4   &5
  macro_fill_fdcat 'UR_NAME'      'User Name'         'X' 'R'  'x'.
  macro_fill_fdcat 'FMNAME'       'Film Name'         ''  'L'  'x'.
  macro_fill_fdcat 'FMCINE'       'Cinma'             ''  'L'  'x'.
  macro_fill_fdcat 'PRICE'        'Price'             ''  'L'  'x'.
  macro_fill_fdcat 'TIC_DATE'     'Purchase Date'     ''  'L'  'x'.
  macro_fill_fdcat 'TIC_STATUS'   'Purchase Status'   ''  'L'  'x'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = lv_repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND_TINFO'
      is_layout_lvc            = ls_layout
      it_fieldcat_lvc          = lt_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_ticinfo_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e007.         "WARNING!!THE INFORMATION YOU TAP IS WRONG!!
  ENDIF.

  FREE: lt_fieldcat, ls_fieldcat, ls_layout.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_TINFO
*&---------------------------------------------------------------------*
*& UUSER_COMMAND_TINFO
*&---------------------------------------------------------------------*
*&      --> R_UCOMM
*&      --> RS_SELFIELD
*&---------------------------------------------------------------------*
FORM user_command_tinfo USING r_ucomm     TYPE sy-ucomm
                             rs_selfield TYPE slis_selfield.
  DATA:
    lv_save_ok TYPE sy-ucomm,
    lr_grid    TYPE REF TO cl_gui_alv_grid.

  lv_save_ok = r_ucomm.

  CASE lv_save_ok.
    WHEN '&DATA_SAVE'.
      PERFORM frm_tic_sell.
      rs_selfield-refresh = abap_true.      "Refresh
    WHEN OTHERS.
      "Do Nothing
  ENDCASE.
  CLEAR:lv_save_ok,lr_grid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_TIC_SELL
*&---------------------------------------------------------------------*
*& Sell Ticket
*&---------------------------------------------------------------------*
FORM frm_tic_sell .
  DATA:
    ls_ticket TYPE zjkt_005_tickets.
  LOOP AT gt_ticinfo_out INTO DATA(ls_ticinfo_out)
      WHERE ( sel = abap_true ).
    ls_ticinfo_out-tic_status = '已出票'.
    MOVE-CORRESPONDING ls_ticinfo_out TO ls_ticket.
    MODIFY gt_ticinfo_out FROM ls_ticinfo_out.
    UPDATE zjkt_005_tickets FROM ls_ticket.
    IF sy-subrc = 0.
      MESSAGE s036.         "Data has been saved successfully.
    ENDIF.
  ENDLOOP.
  CLEAR: ls_ticket,ls_ticinfo_out.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GTE_PRICE_1
*&---------------------------------------------------------------------*
*& Get Price & Cinema
*&---------------------------------------------------------------------*
FORM frm_get_price_1 .
  SELECT SINGLE
    fmname,
    fmcine_1,
    price_1
    FROM zjkt_005_cinema
    WHERE fmname = @gv_fmname
    INTO @DATA(ls_price).
  IF sy-subrc = 0.
    gv_cine = ls_price-fmcine_1.
    gv_price = ls_price-price_1.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_PRICE_2
*&---------------------------------------------------------------------*
*& Get Price & Cinema
*&---------------------------------------------------------------------*
FORM frm_get_price_2 .
  SELECT SINGLE
    fmname,
    fmcine_2,
    price_2
    FROM zjkt_005_cinema
    WHERE fmname = @gv_fmname
    INTO @DATA(ls_price).
  IF sy-subrc = 0.
    gv_cine = ls_price-fmcine_2.
    gv_price = ls_price-price_2.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form FRM_GET_PRICE_3
*&---------------------------------------------------------------------*
*& Get Price & Cinema
*&---------------------------------------------------------------------*
FORM frm_get_price_3 .
  SELECT SINGLE
    fmname,
    fmcine_3,
    price_3
    FROM zjkt_005_cinema
    WHERE fmname = @gv_fmname
    INTO @DATA(ls_price).
  IF sy-subrc = 0.
    gv_cine = ls_price-fmcine_3.
    gv_price = ls_price-price_3.
  ENDIF.
ENDFORM.
