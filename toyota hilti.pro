%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TOYOTA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( toyota_hilti, `06 May 2014` ).

i_date_format( _ ).

i_user_field( invoice, net_subtotal_x, `Subtotal storage` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1 ).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details	
	
	, get_order_number

	, get_invoice_date
	
	, get_buyer_contact_and_email

	, get_delivery_ddi
	
	, get_delivery_contact
	
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

	, buyer_registration_number( `GB-TOYOTA` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `20907861` )
	
	, delivery_party( `TOYOTA TSUSHO UK LTD` )
	
	, buyer_ddi( `01332815210` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q( 0, 5, line ), generic_horizontal_details( [ [ `No`, `.` ], order_number, s1, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,15, line ), generic_horizontal_details( [ [ `Date` ], 100, invoice_date, date, newline ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( delivery_thing( [ Variable, Parameter ] ), [ generic_item( [ Variable, Parameter, gen_eof ] ) ] ).
%=======================================================================
i_line_rule( delivery_header_line, [`Place`, `of`, read_ahead( `Delivery` ), delivery_hook(w) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, delivery_thing( [ delivery_street, s1 ] )
	
	, delivery_thing( [ delivery_city, s1 ] )
	
	, delivery_thing( [ delivery_postcode, pc ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT NUMBERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact_and_email, [ qn0(line), buyer_contact_line, q10( buyer_email_line ) ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [ `Created`, `by`, `:`, tab, generic_item( [ buyer_contact, s1, newline ] ) ] ).
%=======================================================================
i_line_rule( buyer_email_line, [ generic_item( [ buyer_email, s1, newline ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_delivery_ddi, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Tel`, `:` ], delivery_ddi, s1, newline ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ q(0,20,line), delivery_contact_line ] ).
%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	  `FAO`, `-`
	  
	, delivery_contact(sf), or( [ `/`, gen_eof ] )
	
	, trace( [ `delivery_contact`, delivery_contact ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Total`, tab, `£` ], total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Total`, tab, `£` ], total_invoice, d, newline ] )
	
	, with( invoice, net_subtotal_x, Net_x )
	
	, check( sys_calculate_str_subtract( total_net, Net_x, Net_1 ) )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

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
			  
			  line_freight_line
					
			, line_invoice_line

			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Description`, tab, or( [ `Spec`, `Item` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n(anything), tab, `Total`, tab ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [ [ line_item(f( [ begin, q(dec,4,10), end ] ) )
	
			, generic_item( [ line_descr, s1, tab ] )
			
		]
		
		, [ generic_item( [ line_descr, s1, tab ] )
		
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ], q01( tab ) ] )
			
			, generic_item( [ spec, s1, tab ] )
			
		]
		
	] )
	
	, generic_item( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )

	, `£`, tab,  generic_item( [ line_unit_amount, d, tab ] ) 

	, `£`, tab, generic_item( [ line_net_amount, d, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_freight_line, [
%=======================================================================

	  `Delivery`, q10( `charge` )
	  
	, qn0(anything), tab
	
	, generic_item( [ net_subtotal_2, d, newline ] )
	
	, check( net_subtotal_2 = Net )
	
	, net_subtotal_x( Net )
	
	, gross_subtotal_2( Net )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).