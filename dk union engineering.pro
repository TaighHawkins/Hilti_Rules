%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK KONTECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_kontech, `27 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_contact

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
	    , suppliers_code_for_buyer( `11282040` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10550149` ) ]    %TEST
	    , delivery_note_number( `11282040` )                      %PROD
	]) ]
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Indkøbsordre` ], `Indkøbsordre`, order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `Dato` ], `Dato`, invoice_date_x, s1 ] )
	  
	, check( i_user_check( danish_month_change, invoice_date_x, Date ) )
	
	, invoice_date( Date )
	
	, trace( [ `Invoice Date`, Date ] )
	
] ).

%=======================================================================
i_user_check( danish_month_change, Date_In, Date_Out ):-
%=======================================================================

	string_to_lower( Date_In, Date_L ),
	sys_string_split( Date_L, ` `, [ Date_Dan | _ ] ),
	sys_string_split( Date_Dan, `-`, [ Day, Month, Year ] ),
	date_lookup( Month, Number ),
	sys_stringlist_concat( [ Day, Number, Year ], `/`, Date_Out )
.

date_lookup( `januar`, `01` ).
date_lookup( `jan`, `01` ).
date_lookup( `februar`, `02` ).
date_lookup( `feb`, `02` ).
date_lookup( `marts`, `03` ).
date_lookup( `mar`, `03` ).
date_lookup( `april`, `04` ).
date_lookup( `apr`, `04` ).
date_lookup( `kan`, `05` ).
date_lookup( `juni`, `06` ).
date_lookup( `jun`, `06` ).
date_lookup( `juli`, `07` ).
date_lookup( `jul`, `07` ).
date_lookup( `august`, `08` ).
date_lookup( `aug`, `08` ).
date_lookup( `september`, `09` ).
date_lookup( `sep`, `09` ).
date_lookup( `oktober`, `10` ).
date_lookup( `okt`, `10` ).
date_lookup( `november`, `11` ).
date_lookup( `nov`, `11` ).
date_lookup( `december`, `12` ).
date_lookup( `dec`, `12` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Bestiller` ], 150, buyer_contact, s1, newline ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), total_header_line, get_totals_line ] ).
%=======================================================================
i_line_rule( total_header_line, [ `Nettobeløb`, `DKK` ] ).
%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	  read_ahead( [ generic_item( [ total_net, d, newline] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )
	  
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
			  
			, line_continuation_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, q10( tab ), `Varenummer` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Nettobeløb` ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ peek_fails( or( [ `Ordren`, `Ordrebekræftelse` ] ) ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )

	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s, q10( tab ) ] )
	
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )

	, generic_item( [ line_item, w, tab ] )

	, or( [ generic_item( [ line_original_order_date, date, tab ] )
	
		, [ some_date(s1), tab

			, check( i_user_check( danish_month, some_date, Date ) )
			
			, line_original_order_date( Date )
			
			, trace( [ `Date with lookup`, Date ] )
			
		]
		
	] )
	
	, generic_item( [ line_quantity, d ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_user_check( danish_month, Date_In, Date_Out ):-
%=======================================================================

	string_to_lower( Date_In, Date_L ),
	sys_string_split( Date_L, `-`, [ Day, Month, Year ] )
	, date_lookup( Month, Number )
	, sys_stringlist_concat( [ Day, Number, Year ], `/`, Date_Out )
.

date_lookup( `januar`, `01` ).
date_lookup( `jan`, `01` ).
date_lookup( `februar`, `02` ).
date_lookup( `feb`, `02` ).
date_lookup( `marts`, `03` ).
date_lookup( `mar`, `03` ).
date_lookup( `april`, `04` ).
date_lookup( `apr`, `04` ).
date_lookup( `kan`, `05` ).
date_lookup( `juni`, `06` ).
date_lookup( `jun`, `06` ).
date_lookup( `juli`, `07` ).
date_lookup( `jul`, `07` ).
date_lookup( `august`, `08` ).
date_lookup( `aug`, `08` ).
date_lookup( `september`, `09` ).
date_lookup( `sep`, `09` ).
date_lookup( `oktober`, `10` ).
date_lookup( `okt`, `10` ).
date_lookup( `november`, `11` ).
date_lookup( `nov`, `11` ).
date_lookup( `december`, `12` ).
date_lookup( `dec`, `12` ).
