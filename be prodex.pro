%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BE Prodex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_prodex, `28 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_contact
	
	, get_delivery_email
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
	,set( delivery_note_ref_no_failure )
	
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

	, buyer_registration_number( `BE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `10066407` )                 %PROD
	]) ]
	
			
	%, delivery_party( `Prodex` )
	, sender_name( `Prodex` )
	, buyer_dept(`0013684195`)
	, delivery_from_contact(`0013684195`)
	
	, set( reverse_punctuation_in_numbers )
	
	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Bestelbonnummer`], 200, order_number, s1 ] )
	  
	, set(leave_spaces_in_order_number)
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Besteldatum` ],250,  invoice_date, date ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_rule( get_delivery_details, [
%======================================================================================================

	q(0,200,line), generic_horizontal_details( [ [read_ahead([ `Leveradres`, `:`]) ], delivery_hook,s1, tab ] )
	
	, get_delivery_party
	
	%, q(0,2,line),  get_delivery_thing( [ delivery_party])
	
	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	
	, get_delivery_PC
	
	

]).


%======================================================================================================
i_line_rule( get_delivery_party, [
%======================================================================================================

	read_ahead(`prodex`), delivery_party(w), append(delivery_party(w), `-`, ``), append(delivery_party(w), ` `, ``), tab, dummy(s), tab, dummy(s), newline


]).
%======================================================================================================
i_line_rule( get_delivery_PC, [
%======================================================================================================

	nearest(delivery_hook(start), 10, 10 ),  generic_item( [delivery_postcode, d]),  generic_item( [delivery_city, s1])


]).


%======================================================================================================
i_line_rule( get_delivery_thing( [ Variable ] ), [ nearest( delivery_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_email, [ 
%=======================================================================

	q(0,100,line), generic_horizontal_details( [ [read_ahead([ `FAX`, `+`, `32`]) ], email_hook,s1, newline ] )
	  
	, q(0,2,line),  email_hook_thing( [ delivery_email])
	
	, check( delivery_email = Email )
	
	, buyer_email( Email )

] ).


%======================================================================================================
i_line_rule( email_hook_thing( [ Variable ] ), [ nearest( email_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================


%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [ `*`, `Besteld`, `door`], delivery_contact_x, s1 ] )
	
	, check( delivery_contact_x = Con_x )
	, check( string_string_replace( Con_x, ` De `, ` `, Con ) ) 
	
	, delivery_from_contact( Con )
	%, buyer_dept( Con )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `totaal`, `eur` ], total_net, d ] )

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
		
			  line_invoice_rule
			  
			   , line_item_line
			  
				, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `ART`, `.`, `NR`, `.`, tab, `PRIJS`, tab, `LEVERDATUM`,  newline ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ 
	
		[`Algemeen`,  newline ]
		

	
		, [ `Totaal`, `EUR`, tab, dummy(d), newline ]
		
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [  append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_order_line_number(d)
	
	, tab
	
	, line_descr(s)
	
	, or([

		[tab, line_quantity(d), tab, read_ahead(`EA`), dummy(w), tab]
		,
		[tab, append(line_descr(s), ` `, ``), tab, line_quantity(d), tab, read_ahead(`EA`), dummy(s), tab]
		,
		[tab, append(line_descr(s1), ` `, ``), tab, append(line_descr(s1), ` `, ``), tab, line_quantity(d),tab, read_ahead(`EA`), dummy(w), tab]
		,
		[`(`, box_amount(s), `.`, `)`, tab, line_quantity_line, read_ahead(`box`), dummy(w), tab, line_box_amount_x]
		,
		[`(`, box_amount(s), `.`, `)`, tab, append(line_descr(s1), ` `, ``), tab, line_quantity_line,  dummy(w), tab, line_box_amount_x]
		,
		[`(`, box_amount(s), `.`, `)`, tab, append(line_descr(s1), ` `, ``), tab, line_quantity_line, dummy(w), tab, line_box_amount_x]
		,
		[`(`, box_amount(s), `.`, `)`, tab, append(line_descr(s), ` `, ``), tab, `HILTI`, tab, line_quantity_line,  dummy(w), tab]
		
		
		])
		
		, or([
		
		[line_net_amount(d), `EUR`, tab, read_ahead(line_original_order_date(date)), delivery_date(date), newline]
		
		,
		
		[line_net_amount(d), tab, `EUR`, tab, read_ahead(line_original_order_date(date)), delivery_date(date), newline]
		
		])
	

] ).


%=======================================================================
i_rule_cut( line_quantity_line, [
%=======================================================================

	  line_quantity_x(d)
	 
	 , tab
	 
	 , trace([`line_quantity_x`, line_quantity_x])
	 
	, check( box_amount = Ord_X )	
	, check( extract_pattern( Ord_X , Ord, [ dec, dec, dec ] ) )
	, box_amount_x(Ord) 
	
	, trace([`box_amount_x`, box_amount_x])
	 	 
	, check(i_user_check(gen_str_multiply, box_amount_x, line_quantity_x, Qty  ) )
	
	, line_quantity(Qty)
	
	, trace([`line_quantity`, line_quantity])
	
	, remove( box_amount )‏
	, remove( line_quantity_x )‏


] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	 or([
	 
	 [`Uw`, `art`, `.`, `nr`, `.`, `:`, line_item(d), newline]
	 
	 ,
	 
	 [`Uw`, `art`, `.`, `nr`, `.`, `:`, line_item(d), `=`, dummy(d), newline]

	 ,
	 
	 [`Uw`, `art`, `.`, `nr`, `.`, `:`, line_item(d), `­`,  newline]
	 
	 ])
	
] ).



%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).