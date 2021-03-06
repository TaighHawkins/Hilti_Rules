%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH IWB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_iwb, `18 August 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).

i_format_postcode( X, X ).

i_pdf_parameter( no_scaling, 1 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, gen_capture( [ [ `<`, `BELNR`, `>` ], order_number, sf, `<` ] )
	, get_invoice_date
	
	, gen_capture( [ [ `<`, `NAME1`, `>` ], delivery_party, sf, `<` ] )
	, gen_capture( [ [ `<`, `STRAS`, `>` ], delivery_street, sf, [ q10( [ tab, append( delivery_street(sf), ` `, `` ) ] ), `<` ] ] )
	, gen_capture( [ [ `<`, `ORT01`, `>` ], delivery_city, sf, `<` ] )
	, gen_capture( [ [ `<`, `PSTLZ`, `>` ], delivery_postcode, sf, `<` ] )
	
	, gen_capture( [ [ `<`, `BNAME`, `>` ], buyer_contact, sf, [ q10( [ tab, append( buyer_contact(sf), ` `, `` ) ] ), `<` ] ] )
	, gen_capture( [ [ `<`, `BNAME`, `>` ], delivery_contact, sf, [ q10( [ tab, append( delivery_contact(sf), ` `, `` ) ] ), `<` ] ] )
	, get_buyer_and_delivery_ddi

	, get_invoice_lines
	
	, gen_capture( [ [ `<`, `SUMME`, `>` ], total_net, d, `<` ] )
	, gen_capture( [ [ `<`, `SUMME`, `>` ], total_invoice, d, `<` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	sender_name(`IWB`)
	
	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, suppliers_code_for_buyer( `21142275` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q0n(line), invoice_date_line ] ).
%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================
   
	  `<`, `DATUM`, `>`, generic_item( [ invoice_date_x, sf, `<` ] )
	
	, check( i_user_check( modify_numeric_date_y_m_d, invoice_date_x, Date ) )
	
	, invoice_date(Date), trace( [ `invoice_date`, invoice_date ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( modify_numeric_date_y_m_d, DATE_IN, DATE_OUT )
%-----------------------------------------------------------------------
:-
	q_regexp_match( `^\\d{8}$`, DATE_IN, _ ),
	q_sys_sub_string( DATE_IN, 1, 4, YEAR ),
	q_sys_sub_string( DATE_IN, 5, 2, MONTH ),
	q_sys_sub_string( DATE_IN, 7, 2, DAY ),
	strcat_list( [ YEAR, `-`, MONTH, `-`, DAY ], DATE_OUT )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_ddi, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `<`, `TELF1`, `>` ], ddi, sf, [ q(2,0, [ tab, append( ddi(sf), ` `, `` ) ] ), `<` ] ] )
	
	, check( i_user_check( clean_up_ddi, ddi, DDI ) )
	
	, buyer_ddi(DDI)
	, delivery_ddi(DDI)
	
	, trace( [ `got buyer and delivery ddi`, DDI ] )

] ).

%-----------------------------------------------------------------------
i_user_check( clean_up_ddi, DDI_IN, DDI_OUT )
%-----------------------------------------------------------------------
:-
	strip_string2_from_string1( DDI_IN, ` `, DDI ),
	strcat_list( [ `0`, DDI ], DDI_OUT )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n( or( [

			generic_horizontal_details( [ [ `<`, `POSEX`, `>` ], line_order_line_number, sf, `<` ] )
			
			, generic_horizontal_details( [ [ `<`, `MENEE`, `>` ], line_quantity_uom_code, sf, `<` ] )
			
			, generic_horizontal_details( [ [ `<`, `MENGE`, `>` ], line_quantity, d, `<` ] )
			
			, line_original_order_date_line
			
			, generic_horizontal_details( [ [ `<`, `IDTNR`, `>` ], line_item, sf, `<` ] )
			
			, generic_horizontal_details( [ [ `<`, `KTEXT`, `>` ], line_descr, s, `<` ] )
			
			, generic_horizontal_details( [ [ `<`, `NETWR`, `>` ], line_net_amount, d, `<` ] )
			
			, line
	
	] ) )
	
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`<`, `E1EDP01`, q0n(anything), `>`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`<`, `/`, `E1EDP01`, `>`

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================
   
	  `<`, `EDATU`, `>`, generic_item( [ line_original_order_date_x, sf, `<` ] )
	
	, check( i_user_check( modify_numeric_date_y_m_d, line_original_order_date_x, Date ) )
	
	, line_original_order_date(Date), trace( [ `line_original_order_date`, line_original_order_date ] )
	
] ).