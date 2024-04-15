*&---------------------------------------------------------------------*
*& Include          ZJK_PG_005_GRAD_PROJ_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*& Status 9000
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '900'.
*  PERFORM frm_pic.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9100 OUTPUT
*&---------------------------------------------------------------------*
*& Status 9100
*&---------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  SET PF-STATUS '9100'.
  SET TITLEBAR '910'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9200 OUTPUT
*&---------------------------------------------------------------------*
*&  Status 9200
*&---------------------------------------------------------------------*
MODULE status_9200 OUTPUT.
  SET PF-STATUS '9200'.
  SET TITLEBAR '920'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9300 OUTPUT
*&---------------------------------------------------------------------*
*& STATUS 9300
*&---------------------------------------------------------------------*
MODULE status_9300 OUTPUT.
  SET PF-STATUS '9300'.
  SET TITLEBAR '930'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9400 OUTPUT
*&---------------------------------------------------------------------*
*& Status 9400
*&---------------------------------------------------------------------*
MODULE status_9400 OUTPUT.
  SET PF-STATUS '9400'.
  SET TITLEBAR '940'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9500 OUTPUT
*&---------------------------------------------------------------------*
*&  Status 9500
*&---------------------------------------------------------------------*
MODULE status_9500 OUTPUT.
  SET PF-STATUS '9500'.
  SET TITLEBAR '950'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module INITIAL_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&  Init Sub Screen
*&---------------------------------------------------------------------*
MODULE initial_screen OUTPUT.
  IF gv_dynnr IS INITIAL
    OR gv_dynnr = '9510'
    OR gv_dynnr = '9520'.
    tabstrip_film-activetab = 'TAB1'.
    gv_dynnr = '9310'.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module INITIAL_9050 OUTPUT
*&---------------------------------------------------------------------*
*& Init Tabstrip 9050
*&---------------------------------------------------------------------*
MODULE initial_9050 OUTPUT.
  IF gv_dynnr IS INITIAL
    OR gv_dynnr = '9310'
    OR gv_dynnr = '9320'
    OR gv_dynnr = '9330'.
    tabstrip_user-activetab = 'TAB1'.
    gv_dynnr = '9510'.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9520 OUTPUT
*&---------------------------------------------------------------------*
*& Status 9520 Show Search List
*&---------------------------------------------------------------------*
MODULE status_9520 OUTPUT.
  "CREAT CONTAINER
  IF gr_container IS NOT BOUND.
    gr_container = NEW cl_gui_custom_container( container_name = 'CONTAINER_01' ).

    "CREAT ALV
*TRY.
    cl_salv_table=>factory(
      EXPORTING
        list_display   = abap_false
        r_container    = gr_container
        container_name = 'CONTAINER_01'
      IMPORTING
        r_salv_table   = gr_table
      CHANGING
        t_table        = gt_search_out ).
* CATCH cx_salv_msg .
*ENDTRY.
    "SET ALV

    gr_functions = gr_table->get_functions( ).                    "FUNCTION BUTTONS
    gr_functions->set_all( abap_true ).

    gr_display = gr_table->get_display_settings( ).               "Settings for Display
    gr_display->set_striped_pattern( gr_display->true ).          "Set Striped Pattern
    gr_display->set_list_header( 'Search Result' ).               "Set Heading
    gr_display->set_vertical_lines( gr_display->false ).          "Activate or Deactivate Vertical Lines
    gr_display->set_horizontal_lines( gr_display->false ).        "Activate or Deactivate Horizontal Lines

    gr_columns = gr_table->get_columns( ).                        "GET COLUMNS OBJECTS
    gr_columns->set_optimize( ).                                  "SET BLACK AND WHITE LINES
    "DISPLAY ALV
    gr_table->display( ).
  ELSE.
    gr_columns->set_optimize( ).                                  "SET BLACK AND WHITE LINES
    gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).  "REFRESH

  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9530 OUTPUT
*&---------------------------------------------------------------------*
*&  Status 9530
*&---------------------------------------------------------------------*
MODULE status_9530 OUTPUT.
  "CREAT CONTAINER
  IF gr_container_9530 IS NOT BOUND.

    gr_container_9530 = NEW cl_gui_custom_container( container_name = 'CONTAINER_02' ).

    "CREAT ALV
*TRY.
    cl_salv_table=>factory(
      EXPORTING
        list_display   = abap_false
        r_container    = gr_container_9530
        container_name = 'CONTAINER_02'
      IMPORTING
        r_salv_table   = gr_table_9530
      CHANGING
        t_table        = gt_fav_out ).
* CATCH cx_salv_msg .
*ENDTRY.
    "SET ALV

    gr_functions_9530 = gr_table_9530->get_functions( ).                    "FUNCTION BUTTONS
    gr_functions_9530->set_all( abap_true ).

    gr_display_9530 = gr_table_9530->get_display_settings( ).               "Settings for Display
    gr_display_9530->set_striped_pattern( gr_display_9530->true ).          "Set Striped Pattern
    gr_display_9530->set_list_header( 'Favourite Films' ).                  "Set Heading
    gr_display_9530->set_vertical_lines( gr_display_9530->false ).          "Activate or Deactivate Vertical Lines
    gr_display_9530->set_horizontal_lines( gr_display_9530->false ).        "Activate or Deactivate Horizontal Lines

    gr_columns_9530 = gr_table_9530->get_columns( ).                        "GET COLUMNS OBJECTS
    gr_columns_9530->set_optimize( ).                                       "SET BLACK AND WHITE LINES
    "DISPLAY ALV
    gr_table_9530->display( ).
  ELSE.
    gr_columns_9530->set_optimize( ).                                       "SET BLACK AND WHITE LINES
    gr_table_9530->refresh( refresh_mode = if_salv_c_refresh=>full ).       "REFRESH

  ENDIF.
ENDMODULE.
