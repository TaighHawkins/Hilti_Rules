%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR SOTIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_sotis, `31 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

% i_pdf_parameter( same_line, 6 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables 

	, get_order_number_and_date
	
	, gen_capture( [ [ `D`, `.` ], delivery_date, date, gen_eof ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines
	
	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Sotis` )

	, [ or([
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `11721937` )                      %PROD
	]) ]
	
	, or( [
		[ test( test_flag ), delivery_note_number( `10558391` ) ]
			, delivery_note_number( `11721937` )
	] )
	
	, set( delivery_note_ref_no_failure )
	
	, type_of_supply( `01` )
	
	, delivery_from_contact( `FRSOT0018262883` )
	
	, buyer_dept( `FRSOT0018262883` )
	
	, set( leave_spaces_in_order_number )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [
%=======================================================================

	  q(0,25,line)
	  
	, generic_line( [ `COMMANDE` ] )
	
	, q(0,4,line)
	
	, order_number_and_date_line(1,-500,-100)

] ).

%=======================================================================
i_line_rule( order_number_and_date_line, [
%=======================================================================

	  generic_item( [ invoice_date, date, tab ] )
	
	, generic_item( [ order_number, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Date`, `:`, tab ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	
	, q10( [ q0n( [ peek_fails( line_end_line ), line ] )
	
		, generic_horizontal_details( [ [ `FLEET` ] ] ), force_result( `defect` ), force_sub_result( `fleet` )
		
	] )

	, q0n(

		or( [ line_invoice_rule

			, line

		] )

	)
	
	, line_end_line
	
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `RAVINET`, newline

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  set( regexp_cross_word_boundaries ), a(d), tab, a(d), `%`, tab, a(d), clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q01( generic_descr_append )
	
	, or( [
	
		generic_horizontal_details( [ [ `V`, `/`, `REF`, `:` ], line_item, s1, newline ] )
		
		, generic_line( [ [ `V`, `/`, `REF`, `:`, newline ] ] )
		
	] )
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
	] )

	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ doss_, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( set( regexp_cross_word_boundaries ) )
	
	, generic_no( [ line_quantity_x, d, q10(`x`) ] )
	
	, or( [
	
		per(d)
		
		, [ or( [ `PCE`, `UNITE` ] ), per(`1`) ]
		
		, [ `MIL`, per(`1000`) ]
		
	] ), q10(tab)
	
	, check( sys_calculate_str_multiply( per, line_quantity_x, Qty ) )
	
	, line_quantity( Qty )
	, trace( [ `line_quantity`, line_quantity ] )
	
	, generic_no( [ not_unit_amount_, d, q10(tab) ] )
	
	, generic_no( [ not_unit_amount_, d, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line), invoice_totals_line
	
] ).

%=======================================================================
i_line_rule( invoice_totals_line, [
%=======================================================================

	  set( regexp_cross_word_boundaries )
	
	, generic_no( [ total_net, d, tab ] )
	, check( total_net = Net )
	, total_invoice( Net )
	
	, generic_no( [ vat_rate_x, d, [ `%`, tab ] ] )
	
	, generic_no( [ total_vat_x, d, tab ] )
	
	, generic_no( [ total_invoice_x, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )
	
] ).