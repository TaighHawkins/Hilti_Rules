%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US Telect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_prodex, `13 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
		
	, get_delivery_contact
	

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_invoice_lines_2

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

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	%, Qualf(`6000`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11265913` ) ]    %TEST
	    , suppliers_code_for_buyer( `20767630` )                      %PROD
	]) ]
	
	,buyer_registration_number(`US-ADAPTRI`)
	
	, cost_centre(`Standard`)
	, type_of_supply(`01`)
	
	, sender_name( `Telect - US` )
	
	



] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER Suppliers Code AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `PO`, `Number`, `:`], 100, order_number, s ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], order_date, date ] )
	  
	  , check(order_date = DATE)
	  
	  , invoice_date( DATE)
	  	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%======================================================================================================
i_rule( get_delivery_details, [
%======================================================================================================

	q(0,200,line), generic_horizontal_details( [ [`Hilti`, `,`, `Inc`, `.`],350, delivery_party_x,s1 ] )
	
	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	, get_delivery_postcode
	
	, delivery_party(`TELECT INC`)
	
]).


%======================================================================================================
i_line_rule( get_delivery_thing( [ Variable ] ), [ nearest( delivery_party_x(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================



%======================================================================================================
i_line_rule( get_delivery_postcode, [ 
%======================================================================================================
	
	
	dummy(s), tab
	
	, delivery_city(s)
	
	, set( regexp_allow_partial_matching )
	, read_ahead([dummy(f( [ q(alpha,2,2) ] ) )])
	, clear( regexp_allow_partial_matching )‏
	
	, delivery_state(w)
	
	, delivery_postcode(d), newline



]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	 q(0,300,line), generic_horizontal_details( [ [`Authorized`, `By`, `:`], delivery_contact, s ] )

	,	q(0,2,line), generic_horizontal_details( [ delivery_email, s ] )
	
	, check( delivery_contact = DELCON )
	
	, check( delivery_email = DELEMAIL )
	
	, buyer_contact( DELCON)
	, buyer_email(DELEMAIL)
	 

	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Line`, `(`, `s`, `)`, `Subtotal`, `:` ], 100, total_net, d ] )
	
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

		  or( [ 
		
			  line_invoice_line
			  
			  , line_conitinuation_line
			  
			 , line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Line`, tab, `Part`, `Number`, `/`, `Rev`, `/`, `Description`, tab, `Order`, `Qty`, `.`, tab, `Unit`, `Price`, tab, `Ext`, `Price`, tab, `Tax`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	`-`, `Shipping`, `Release`, `Requirement`, `-`, tab, `Release`, `Due`, `Date`, tab, `Quantity`,  newline
	
] ).

%=======================================================================
i_line_rule_cut( line_conitinuation_line, [
%=======================================================================

	  append(line_descr(s), ` `, ``), newline
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	or([
	
	[line_order_line_number(d), tab, line_item_for_buyer(s), tab, dummy(w),tab,  line_quantity(d), `EA`, tab, unit(s), tab, line_net_amount(d), tab, tax(w), newline, line_quantity_uom_code(`PC`)]

	,
	[line_order_line_number(d), tab, line_item_for_buyer(s), tab, dummy(w),tab, line_quantity(d), uom_dummy(w), tab, unit(s), tab, line_net_amount(d), tab, tax(w), newline]

	])

] ).

%=======================================================================
i_section( get_invoice_lines_2, [
%=======================================================================

	  line_header_line_2
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_line_2
			  
			 , line

		] )

	] )
		
	, line_end_line_2

] ).


%=======================================================================
i_line_rule_cut( line_header_line_2, [ `Manufacturer`, tab, `Mfg`, `Part`, `Number`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line_2, [ 
%=======================================================================

	
	`Line`, tab, `Part`, `Number`, `/`, `Rev`, `/`, `Description`, tab, `Order`, `Qty`, `.`, tab, `Unit`, `Price`, tab, `Ext`, `Price`, tab, `Tax`,  newline
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_2, [
%=======================================================================

	or([
	
		
	[dummy(d), tab, due_date(date), tab, dummy(d), uom_dummy(w), newline]
	
	
	])

] ).

