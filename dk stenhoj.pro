%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK STENHOJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_stenhoj, `24 September 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	 
	, check_order_format

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_dept

	, get_invoice_lines
	
	, get_landscape_invoice_lines

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

	, buyer_registration_number( `DK-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10550149` ) ]    %TEST
	    , suppliers_code_for_buyer( `11279101` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK ORDER FORMAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_order_format, [
%=======================================================================	  
	  
	  or( [ [ q(0,20,line), generic_horizontal_details( [ read_ahead( [ `Internt`, tab, `Leverandør` ] ), dummy, s1 ] )
	  
			, set( landscape ), trace( [ `Landscape Order` ] )
			
		]
		
		, [ set( portrait ), trace( [ `Portrait Order` ] ) ]
		
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ Order_Search, order_number, s1, newline ] )
	
] ):-
	( grammar_set( portrait ), Order_Search = `Indkøbsordre`
	;	grammar_set( landscape ), Order_Search = [ `ORDRENR`, `.`, `:` ]
	)
.

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Dato`, q10( `:` ) ], invoice_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_dept, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ Dept_Search, buyer_dept_x, w ] )
	
	, check( string_to_upper( buyer_dept_x, Dept_x ) )
	
	, check( strcat_list( [ `DKSTEN`, Dept_x ], Dept ) )
	
	, buyer_dept( Dept )
	
	, delivery_from_contact( Dept )
	
] ):-
	( grammar_set( portrait ), Dept_Search = [ `Sagsbeh`, `.`, `:` ]
	;	grammar_set( landscape ), Dept_Search = [ `Bestiller`, `:` ]
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	or( [ [ test( test_flag ), delivery_note_number( `10550149` ) ]
		, delivery_note_number( `11279101` )
	] )
	
] ):-	grammar_set( landscape ).

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ read_ahead( `Leveringsadresse` ), delivery_hook, s1, newline ] )
	
	, delivery_thing_line( [ delivery_party ] )
	
	, delivery_thing_line( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ):-	grammar_set( portrait ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ nearest( delivery_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ). 
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [ 
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	  
	, generic_item( [ delivery_city, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( total_header_line, [ q0n(anything), tab, read_ahead( `Mængde` ), total_hook(s1) ] ):- grammar_set( landscape ).
%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	total_net( `0` )
	
	, total_invoice( `0` )
	
	, q0n(line), total_header_line
	
	, qn0( [ or( [ add_total_line, line ] ) ] )
	
	, trace( [ `totals`, total_net ] )
	
] ):- grammar_set( landscape ).

%=======================================================================
i_line_rule( add_total_line, [ 
%=======================================================================

	nearest( total_hook(end), 10, 10 )
	
	, total(d)
	
	, check( sys_calculate_str_add( total_net, total, Net ) )
	
	, total_net( Net )
	
	, total_invoice( Net )
	
] ).

%=======================================================================
i_rule( get_totals, [ qn0(line), total_header_line, get_totals_line ] ):- grammar_set( portrait ).
%=======================================================================
i_line_rule( total_header_line, [ `Nettobeløb` ] ):- grammar_set( portrait ).
%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	  read_ahead( [ generic_item( [ total_net, d ] ) ] )
	
	, generic_item( [ total_invoice, d ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ):-	grammar_set( portrait ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Vare`, `nr`, `.`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ `Nettobeløb`, `Leveringsadresse` ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ [ test( short_line ), clear( short_line ) ]
	
		, [ peek_fails( test( short_line ) )
	
			, line_descr( `` )
			
			, q(0,4, or( [ line_hyphen_line, line_descr_line ] ) )
			
			, line_item_line
			
		]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_hyphen_line, [ `-`, `-`, `-` ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ append( line_descr(s1), ``, ` ` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ generic_item( [ line_item, [ begin, q(dec,3,10), end ], newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, s1, tab ] )

	, or( [ [ generic_item( [ line_descr, s, [ generic_item( [ line_item, [ begin, q(dec,3,10), end ] ] ), tab ] ] )
	
			, set( short_line )
			
		]
		
		, generic_item( [ line_descr_x, s1, tab ] )
		
	] )
	
	, generic_item( [ line_quantity, d ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ unit_uom, s1, tab ] )
	
	, q01( generic_item_cut( [ line_percent_discount, d, q10( tab ) ] ) )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LANDSCAPE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_landscape_invoice_lines, [
%=======================================================================

	  line_landscape_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_landscape_invoice_rule

			, line

		] )

	] )

	, line_landscape_end_line

] ):-	grammar_set( landscape ).


%=======================================================================
i_line_rule_cut( line_landscape_header_line, [ `kontonr`, `.`, tab, `varenr`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_landscape_end_line, [ `BURET` ] ).
%=======================================================================
i_rule_cut( line_landscape_invoice_rule, [
%=======================================================================

	  line_landscape_invoice_line
	
] ).

%=======================================================================
i_line_rule_cut( line_landscape_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_item, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, peek_fails( `0` )

	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, newline ] )
	
	, line_unit_amount( `1` )

] ).