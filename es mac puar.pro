%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MAC PUAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( mac_puar, `20 April 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_buyers_code_for_buyer
	
	, get_delivery_note_number

	, get_order_number

	, get_invoice_date

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

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `ES-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Mac - Puar, S.A.` )
	, set( leave_spaces_in_order_number )
	, set( reverse_punctuation_in_numbers )
	, set( no_scfb )
	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,35,line)
	  
	, read_ahead( generic_vertical_details( [ [ `Pedido`, `de`, `compra`, `nº` ], `de`, order_number, s1 ] ) )
	
	, generic_vertical_details( [ `Comprador`, some_name, s1 ] )
	, check( i_user_check( strip_out_initials, some_name, Con, Initials ) )
	, buyer_contact( Con )
	, delivery_contact( Con )
	
	, append( order_number( Initials ), ` `, `` )
	
] ).

%=======================================================================
i_user_check( strip_out_initials, NameIn, Con, Initials ) 
%=======================================================================
:-
	sys_string_split( NameIn, ` `, NameSplit ),
	NameSplit = [ FirstName | _ ],
	sys_reverse( NameSplit, [ Surname | _ ] ),
	wordcat( [ FirstName, Surname ], Con ),
	trace( `About to strip` ),
	strip_out_initials( NameSplit, InitialsList ),
	trace( got_initials( InitialsList ) ),
	strcat_list( InitialsList, Initials )
.

strip_out_initials( [ H | T ], [ HI | TI ] )
:-
	q_sys_sub_string( H, 1, 1, HI ),
	trace( [ `Got`, HI, `From`, H ] ),
	( T = [ ]
		;	strip_out_initials( T, TI )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,35,line), generic_vertical_details( [ [ `Fecha`, tab, `Cod` ], invoice_date, date ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyers_code_for_buyer, [
%=======================================================================

	q(0,35,line), generic_horizontal_details( [ at_start, buyers_code_for_buyer, [ begin, q(dec,5,5), end ] ] )
	
	, prepend( buyers_code_for_buyer( `ESMAC` ), ``, `` )
	
] ).

%=======================================================================
i_rule( get_delivery_note_number, [ with( invoice, buyers_code_for_buyer, BCFB ), delivery_note_reference( BCFB ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line)
	  
	, generic_horizontal_details( [ [ `Total`, `Pedido`, q10( [ dummy(s1) ] ) ], 300, total_net, d ] )

	, check( total_net = Net )
	, total_invoice( Net )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Artículos`, tab, `Ref.`, q0n(anything), read_ahead( `Cantidad` ), header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `Pedido` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, q10( generic_item( [ some_code, s1, tab ] ) )
	
	, generic_item_cut( [ line_quantity, d, [ tab, check( line_quantity(end) > header(end) ) ] ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_percent_discount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, q10( [ without( delivery_date ), read_ahead( generic_item( [ delivery_date, date ] ) ) ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.