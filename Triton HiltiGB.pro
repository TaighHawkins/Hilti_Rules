%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Triton Construction Ltd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	Don't forget to update the date when you change the rules!
i_version( triton, `25 February 2014` ).

i_date_format( _ ).
%i_pdf_parameter( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	, get_invoice_date
	, get_order_number
	, get_order_date
	, get_delivery_contact

%	you need this to enable the count rule to work correctly
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
	
	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, buyer_registration_number(`GB-ADAPTRI`)

	, set( purchase_order )
	 
	, delivery_party( `TRITON CONSTRUCTION LIMITED` )
	, sender_name( `Triton Construction Ltd.` )
	

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, suppliers_code_for_buyer(`13200054`)
	, buyer_ddi(`01274 874772`)
	, buyer_contact(`Roger Swift`)
	, buyer_email(`R.Swift@tritonconstruction.co.uk`)


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
ii_rule_cut( get_delivery_location, [
%======================================================================================================
		
		q(0,10,line), generic_horizontal_details( [ [ read_ahead([`ORDER`, `NO`, `:`]) ], header_hook,s1, newline ] )
		,q(0,2,line),generic_horizontal_details( [ delivery_location, s, `/` ] )
		
		
		
]).

%======================================================================================================
i_rule( get_order_number, [
%======================================================================================================
		

	q(0,10,line)
		% , generic_horizontal_details( [ [ read_ahead([`ORDER`, `NO`, `:`]) ], header_hook,s1, newline ] )
		% ,q(0,2,line), generic_horizontal_details( [ order_number,s, newline ])
	
%	This works, maybe you weren't giving it the line count above?		
	, generic_vertical_details( [ [ `Order`, `No`, `:` ], `Order`, end, order_number, s1 ] )‏

	, check( sys_string_split( order_number, `/`, [ Loc | _ ] ) )
	, delivery_location(Loc)
	
]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_rule( get_order_date, [
%======================================================================================================

	q(0,50,line), generic_horizontal_details( [ [ read_ahead([`Delivery`, `Required`]) ], header_hook,s1, tab ] )
	
	, q(0, 2,line), generic_horizontal_details( [ due_date, date, tab])
	
	
	
	
]).

%======================================================================================================
i_rule( get_invoice_date, [
%======================================================================================================
		
		q(0,20,line), generic_horizontal_details( [  [`Your`, `Reference`],150,  date_hook,s1, newline ])
		, q(0,2,line), get_date_thing([invoice_date])
		
		
]).


%======================================================================================================
i_line_rule( get_date_thing( [ Variable ] ), [ nearest( date_hook(start), 30, 30 ), generic_item( [ Variable, date ] ) ] ).
%======================================================================================================




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	Issues here - Only capturing Total Net
%	In order to circumvent the delivery charges we changed the validation to net_subtotal_1 and gross_subtotal_1
%	Capturing this would prevent any validation.
%	The rule underneath works fine, I've just copied your capture bit generic_horizontal_details...
%	and put it inside
%======================================================================================================
ii_rule( get_totals, [
%======================================================================================================
		
		q(0,100,line), generic_horizontal_details( [ [`Total`], 150, total_net, d, newline ] )
		
]).

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [`Total`], 150, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).

%======================================================================================================
i_rule( get_delivery_contact, [
%======================================================================================================


			q(0,50,line),  generic_horizontal_details( [[`Site`, `Contact`, `:`],100, delivery_contact,s, newline])
			, q(0,2,line),  generic_horizontal_details( [[`Site`, `Tel`, `:`], 100, delivery_ddi,s, newline] )
			
				
]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
		  line_invoice_rule
			 
			, line_contiunation_line
			
			 
			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )

	, count_rule
	
] ).


%=======================================================================
i_line_rule_cut( line_contiunation_line, [ append( line_descr(s1), ` `, ``)] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================
	
		`Code`, tab, `Quantity`, tab, `Unit`, tab, `Rate`, tab, `Please`, `supply`, `the`, `following`, `:`, tab, `Price`,  newline
 
		, trace([`found header`])
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================


		`Total`, tab, `£`, dummy(d), newline

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

		
	dummy(s), tab, line_quantity(d), tab
	
	
	, line_quantity_uom_code(s), tab, dummy(d), tab
	
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	
	, line_descr(s), tab, line_net_amount(d), newline
		
	,q10( [ with( invoice, due_date, Date ), line_original_order_date( Date ) ] )
		
] ).


%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).