%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US SUNBELT TOOLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_sunbelt_tools, `26 June 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).
i_user_field( invoice, delivery_location_x, `Delivery Location Raw` ).

i_op_param( o_mail_subject, _, _, SubjectIn, SubjectOut )
:-
	( result( _, invoice, force_sub_result, `special_rule` )
		;	data( invoice, force_sub_result, `special_rule` )
	),
	trace( `Sub` ),
	
	( result( _, invoice, delivery_location_x, Loc )
		;	data( invoice, delivery_location_x, Loc )
	),
	trace( `Loc` ),
	
	strcat_list( [ `Sunbelt Tools - `, Loc, ` - ENTER MANUALLY` ], SubjectOut )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_location

	, get_order_date
	
	, get_order_number

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_due_date
	
	, get_buyer_contact
	, get_buyer_ddi
	, get_buyer_fax
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, suppliers_code_for_buyer( `10754887` )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	, cost_centre( `Standard` )

	, sender_name( `Sunbelt Tools` )
	
	, buyer_email( `sourcing@sunbeltrentals.com` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	  q(0,100,line)
	  
	, generic_horizontal_details( [ [ at_start, `Ship`, `To`, `:` ], delivery_location_x, s1 ] )

	, check( strip_string2_from_string1( delivery_location_x, ` `, Loc ) )
	, delivery_location( Loc )
	
	, trace( [ `Delivery Location`, delivery_location ] )
	
	, q10( [ check( Loc = `PC982` )
		, trace( [ `PC982 rule triggered - document NOT processed` ] )
		, delivery_note_reference( `special_rule` )
		, set( do_not_process )
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `PO`, `#`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Date`, `Ordered`, `:` ], invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Requested`, `Date`, `:` ], raw_delivery_date, date ] )
	  
	, check( i_user_check( add_days_to_date, raw_delivery_date, DateOut ) )
	
	, delivery_date( DateOut )
	, trace( [ `Delivery Date`, delivery_date ] )
	
] ).

i_user_check( add_days_to_date, DateIn, DateOut )
:-
	i_date_format( Format ),
	date_string( DateRaw, Format, DateIn ),
	date_add( DateRaw, days( 4 ), DateOutRaw ),
	date_string( DateOutRaw, Format, DateOut )
.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `From`, `:` ], 200, buyer_contact, s1 ] )
	  
	, q10( [ check( buyer_contact = `SOURCING` )
		, prepend( buyer_contact( `Sunbelt` ), ``, ` ` )
	] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Phone`, `:` ], 200, buyer_ddi_x, s1 ] )
	  
	, check( string_string_replace( buyer_ddi_x, ` `, `-`, DDI ) )
	, buyer_ddi( DDI )

] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Fax`, `#`, `:` ], 200, buyer_fax_x, s1 ] )
	  
	, check( string_string_replace( buyer_fax_x, ` `, `-`, Fax ) )
	, buyer_fax( Fax )

] ).

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `P`, `.`, `O`, `.`, `Total`, `:`, set( regexp_cross_word_boundaries ) ], total_net, d, newline ] )
	, clear( regexp_cross_word_boundaries )

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
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [  line_invoice_rule
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Orig`, tab, `Rcvd` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n( word ), `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, count_rule
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item( [ line_item, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).