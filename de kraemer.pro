%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE KRAEMER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_kraemer, `02 October 2014` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_order_date

	, get_contacts
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	, set( no_total_validation )
	
	, suppliers_code_for_buyer( `10179437` )
	, delivery_note_number( `10179437` )

	, sender_name( `Kraemer Lufttechnik` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `BESTELLUNG`, `-`, `Nr`, `.`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ invoice_date, date, newline ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ `Besteller`, `:` ], buyer_contact_x, s1 ] )
	
	, check( i_user_check( get_the_full_code, buyer_contact_x, Con ) )
	
	, buyer_dept( Con )
	, delivery_from_contact( Con )	

] ).

%=======================================================================
i_user_check( get_the_full_code, Name_In, Con_Out ):- 
%=======================================================================
  
	string_to_upper( Name_In, Con_Y ),
	sys_string_split( Con_Y, ` `, Con_List ),
	sys_reverse( Con_List, [ Surname | _ ] ),

	sys_string_length( Surname, Len ),
	
	(  Len > 10
		->	q_sys_sub_string( Surname, 1, 10, Name )
	
		;	Name = Surname
	),
	
	strcat_list( [ `DEKRAE`, Name ], Con_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================
	  
	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ read_ahead( `Projektnr` ), read_ahead( hook(w) ), retab( [ 500 ] ) ], customer_comments, s1 ] )
	
	, generic_line( [ [ nearest( hook(start), 10, 10 ), retab( [ 500 ] ), append( customer_comments(s1), `~`, `` ) ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  or( [ [ q0n(line), read_ahead( generic_horizontal_details( [ [ at_start, `Gesamt`, `-`, `Betrag` ], total_net, d ] ) )
	  
			, check( total_net = Net )

			, total_invoice( Net )
			
		]
		
		, [ total_net( `0` ), total_invoice( `0` ) ]
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [ 
		
			  line_invoice_rule
			  
			, line_defect_line
		 
			, line_continuation_line

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Posnr`, `Artikel` ] ), header_dummy(s1) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Krämer` ] 
	
		, [ `Gesamt`, `-` ]

%	Default to try and catch the missed end lines		
		, [ end_dummy(s1), check( end_dummy(page) > header_dummy(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
	
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q01( [ `/`, word ] ), tab ] ] )
	
		, line_item( `Missing` )
		
	] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )

	, q10( [ generic_item_cut( [ line_unit_amount, d, [ `€`, tab ] ] )
	
		, generic_item( [ line_percent_discount, d, tab ] )
	
		, generic_item( [ line_net_amount, d, `€` ] )
		
		, line_vat_amount( `0` )

	] )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).


%=======================================================================
i_line_rule_cut( line_defect_line, [ 
%=======================================================================

	q0n(anything), tab, peek_fails( `0`, `,`, `00` )
	
	, dum(d), `€`, some(date)
	
	, force_result( `defect` ), force_sub_result( `missed_line` ) 
	
] ).