%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GROUND CONSTRUCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ground_construction, `18 May 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, check_for_ze_order
	
	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_buyer_email

%	, get_delivery_details
	
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

	, buyer_registration_number( `GB-GROUND` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12311620` )

	, sender_name( `Ground Construction Ltd.` )
	
	, delivery_party( `GROUND CONSTRUCTION LIMITED` )
	
	, buyer_ddi( `0208 238 7000` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_ze_order, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `This`, `Order`, `Has`, `Been`, `Changed` ] ] ) 
	  
	, invoice_type( `ZE` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ at_start, `Order`, `Number`, `:`, retab( [ 200 ] ) ], order_number_x, s1 ] ) 
	  
	, check( i_user_check( check_order_initials, order_number_x, Order, Contact ) )
	
	, order_number( Order )
	
	, buyer_contact( Contact )
	
	, trace( [ `Order Number`, Order] )
	
	, trace( [ `Buyer Contact`, Contact ] )
	
	, check( sys_string_split( Order, `/`, [ _, Loc | _ ] ) )
	, delivery_location( Loc )
	, trace( [ `Delivery location`, Loc ] )
	
] ).

%=======================================================================
i_user_check( check_order_initials, Order_In, Order_Out, Contact )
%-----------------------------------------------------------------------
:-
%=======================================================================

	strip_string2_from_string1( Order_In, ` `, Order_Strip ),
	
	( q_regexp_match( `^.+/[A-Z]{2}$`, Order_Strip, _ )
		->	Order_In = Order_Out
		
		;	q_regexp_match( `^.+/$`, Order_Strip, _ ),
			i_mail( from, From ),
			initial_lookup( From, Initials, Contact ),
			strcat_list( [ Order_Strip, Initials ], Order_Out )
			
		;	q_regexp_match( `^(.+/.+/).+$`, Order_Strip, OrderBase ),
			i_mail( from, From ),
			initial_lookup( From, Initials, Contact ),
			strcat_list( [ OrderBase, Initials ], Order_Out )
	)
.

initial_lookup( `debraawad@groundconstruction.com`, `DA`, `DEBRA AWAD` ).
initial_lookup( `ianberry@groundconstruction.com`, `IB`, `IAN BERRY` ).
initial_lookup( `invoice@groundconstruction.com`, `LC`, `LESLEY CHAPMAN` ).
initial_lookup( `seanconroy@groundconstruction.com`, `SC`, `SEAN CONROY` ).
initial_lookup( `trevordiviney@groundconstruction.com`, `TD`, `TREVOR DIVINEY` ).
initial_lookup( `stevewedwards@gclonsite.com`, `SE`, `STEVE EDWARDS` ).
initial_lookup( `annefennessey@groundconstruction.com`, `AF`, `ANNE FENNESSEY` ).
initial_lookup( `markfernandes@groundconstruction.com`, `MF`, `Mark Fernandes` ).
initial_lookup( `robfitzell@groundconstruction.com`, `RF`, `Rob Fitzell` ).
initial_lookup( `paulfitzsimmons@groundconstruction.com`, `PF`, `PAUL FITZSIMONS` ).
initial_lookup( `simongordon@groundconstruction.com`, `SG`, `SIMON GORDON` ).
initial_lookup( `michaelgreene@groundconstruction.com`, `MG`, `MICHAEL GREENE` ).
initial_lookup( `markgrogan@groundconstruction.com`, `MG`, `MARK GROGAN` ).
initial_lookup( `arrisibrahim@groundconstruction.com`, `AI`, `ARRIS IBRAHIM` ).
initial_lookup( `clarellewellyn@groundconstruction.com`, `CL`, `CLARE LLEWELLYN` ).
initial_lookup( `markgrogan@groundconstruction.com`, `MG`, `MARK GROGAN` ).
initial_lookup( `debraawad@groundconstruction.com`, `AM`, `ANN MOORE` ).
initial_lookup( `jameso``beirne@groundconstruction.com`, `JO`, `JAMES O``BEIRNE` ).
initial_lookup( `jameso'beirne@groundconstruction.com`, `JO`, `JAMES O'BEIRNE` ).
initial_lookup( `ronanriley@groundconstruction.com`, `RR`, `RONAN RILEY` ).
initial_lookup( `kaytrainor@groundconstruction.com`, `KT`, `KAY TRAINOR` ).
initial_lookup( `kaytrainor@groundconstruction.com`, `KT`, `KAY TRAINOR` ).
initial_lookup( `info@groundconstruction.com`, `TT`, `TREVOR TREVOR` ).
initial_lookup( `candywhittle@groundconstruction.com`, `CW`, `CANDY WHITTLE` ).
initial_lookup( `stephenwright@groundconstruction.com`, `SW`, `STEPHEN WRIGHT` ).
initial_lookup( _, `MG`, `MARK GROGAN` ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ invoice_date, date ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Delivery`, `Date`, `:` ], due_date, date ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From )

] )
:-
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(15,0,line), generic_horizontal_details( [ [ `Deliver`, `To`, `:` ] ] )
	
	, q(1,2,line)

	,generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1, newline ] )

	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_city, s1, newline ] )
	
	, q01(line)
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_postcode, pc, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Sub`, `Total`, `:` ], 150, total_net, d, newline ] )

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
i_line_rule_cut( line_header_line, [ `Quantity`, `Unit` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Signed` ] ).
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
	
	, with( invoice, due_date, Date )
	
	, line_original_order_date( Date )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )

	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( `-` ) ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )
	
	, generic_item( [ head, s1, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport`, `quote`, `quotation` ] )
	, trace( `delivery line, line being ignored` )
.