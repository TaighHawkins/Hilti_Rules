%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT IOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_iof, `30 July 2015` ).

%i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

% i_op_param( send_original( _ ), _, _, _, true ).
i_op_param( send_original_name, _, _, _, Name )
:-
	i_mail( attachment, Attach ),
	string_string_replace( Attach, `excel`, `xls`, Name )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_suppliers_code_for_buyer

	, get_order_number

	, get_order_date
	
	, get_due_date
	
	, get_delivery_address
	
	, get_delivery_address_line
	
	, get_buyer_contact
	
	, get_delivery_contact 
	
	, get_customer_comments
	
	, get_shipping_instructions
	
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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Italian Order Form` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  

	q(0,20,line), get_pipe_separated_line( [ [ [ `N`, `°`, `Ordine`, `acquisto`, `:` ], order_number ] ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  

	q(0,20,line), get_pipe_separated_line( [ [ [ `Data`, `Ordine`, `:` ], datex ] ] )
	
	, check( i_user_check( convert_to_usable_date, datex, Date ) )
	, invoice_date( Date )
	, trace( [ `Invoice Date`, Date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  

	q(0,20,line), get_pipe_separated_line( [ [ [ `Data`, `Consegna`, `:` ], datex ] ] )
	
	, check( i_user_check( convert_to_usable_date, datex, Date ) )
	, due_date( Date )
	, trace( [ `Due Date`, due_date ] )
	
] ).

i_user_check( convert_to_usable_date, DateIn, DateOut )
:-
	sys_string_number( DateIn, DateNumPlusTwo ),
	sys_calculate( DateNum, DateNumPlusTwo - 2 ),
	sys_date_1900_days( DatePro, DateNum ),
	sys_date_string( DatePro, `d/m/y`, DateOut )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	FILE RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_pipe_separated_line( [ Num, Var ] ), [ get_pipe_separated_value( [ Num, Var ] ) ] ).
%=======================================================================	
i_line_rule( get_pipe_separated_line( [ List ] ), [ get_pipe_separated_value( [ List ] ) ] ).
%=======================================================================	

%=======================================================================
i_rule( get_pipe_separated_value( [ [ ] ] ), [ ] ).
%=======================================================================
i_rule_cut( get_pipe_separated_value( [ [ H | T ] ] ), [
%=======================================================================

	q0n(anything), H, q10( tab ), `|`
	
	, get_pipe_separated_value( [ T ] )
	
] ):- ( q_sys_is_string( H ); q_sys_is_list( H ) ), !.


%=======================================================================
i_rule_cut( get_pipe_separated_value( [ [ H | T ] ] ), [
%=======================================================================

	generic_item_cut( [ Var, Par, or( [ [ q0n( [ tab, ExtraVar ] ), q01( tab ), `|` ], newline ] ) ] )
	
	, get_pipe_separated_value( [ T ] )

] ):-
	not( q_sys_is_string( H ) ),
	not( q_sys_is_list( H ) ),
		
	( H = ( Var, Par )
	
		;	H = Var, Par = sf
	), !,
	
	ReadVar =.. [ Var, sf ],
	ExtraVar =.. [ append, ReadVar, ` `, `` ],
	!
.

%=======================================================================
i_rule_cut( get_pipe_separated_value( [ Num, Var ] ), [
%=======================================================================
	q(Num,Num, get_to_pipe )

	, generic_item( [ Var, sf, or( [ [ q0n( [ tab, ExtraVar ] ), q01( tab ), `|` ], newline ] ) ] )
	
] ):-
	q_sys_is_number( Num ),
	ReadVar =.. [ Var, sf ],
	ExtraVar =.. [ append, ReadVar, ` `, `` ],
	!
.

%=======================================================================
i_rule_cut( get_to_pipe, [ q0n(anything), `|` ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	or( [ [ test( test_flag ), suppliers_code_for_buyer( `17010320` ) ]
	
		, get_pipe_separated_line( [ [ suppliers_code_for_buyer ] ] )
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ get_pipe_separated_line( [ 1, delivery_note_number ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_delivery_address_line, [
%=======================================================================

	q(0,10,line), generic_horizontal_details_cut( [ [ `CIG`, `:`, `|` ], cig, sf, `|` ] )
	
	, generic_horizontal_details_cut( [ [ `Cup`, `:`, `|` ], cup, sf, `|` ] )
	
	, or( [ [ check( not( q_sys_sub_string( cig, _, _, `|` ) ) )
			, check( cig = Cig )
		]
		
		, [ check( q_sys_sub_string( cig, _, _, `|` ) )
			, check( Cig = `` )
			, set( no_cig )
		]
	] )
	
	, or( [ [ check( not( q_sys_sub_string( cup, _, _, `|` ) ) )
			, check( cup = Cup )
		]
		
		, [ check( q_sys_sub_string( cup, _, _, `|` ) )
			, check( Cup = `` )
			, set( no_cup )
		]
	] )
	
	, or( [ [ test( no_cig ), test( no_cup ) ]
	
		, [ check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
			, delivery_address_line( AL )
		]
	] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ get_pipe_separated_line( [ 2, buyer_location ] ) ] ).
%=======================================================================
i_rule( get_delivery_contact, [ get_pipe_separated_line( [ 3, delivery_from_location ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ q(0,20,line), get_pipe_separated_line( [ [ [ `Commessa`, `:` ], customer_comments ] ] ) ] ).
%=======================================================================
i_rule( get_shipping_instructions, [ q(0,20,line), get_pipe_separated_line( [ [ [ `Informazioni`, `per`, `Corriere`, `:` ], shipping_instructions ] ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ at_start, qn0( `|` ) ], total_net, d, newline ] )

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

			, line

		] )

	] )

	, line_end_line 

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Codice`, `Materiale` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q( 7, 7, `|` ), num(d) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	get_pipe_separated_line( [ [ line_item, line_descr, ( qty_rich, d ), (qty_ven, d ), line_quantity_uom_code, ( prezzo, d ), ( line_quantity, d ), ( line_net_amount, d ) ] ] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).