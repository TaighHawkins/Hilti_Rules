%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Bacon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bacon, `13 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	  
	, [q0n(line), get_del_note]
	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, [ q(0,100,line),get_buyer_contact]
	
	, get_delivery_ddi
		
	, get_delivery_contact
	
	, get_buyer_reg
	
	, get_suppliers_code
	
	, get_del_from_loc
	
	, get_original_date
	
	, [q0n(line), get_customer_comments]
	
	
	, [q0n(line), get_buyer_email]
	, [q0n(line), get_delivery_email]
	
	
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

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `10066407` )                      %PROD
	]) ]
	
	, buyer_registration_number(`AT-ADAPTRI`)
	
	
	, sender_name( `Bacon` )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER Suppliers Code AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_original_date, [
%=======================================================================	  
	  
	  q(0,50,line), generic_horizontal_details( [ [ `Liefertermin`], 100, line_original_order_date, date ] )
	  
	  
] ).

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Bestellung`], 300, order_number, s ] )
	  
	  , order_number_line
	
] ).

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================	  
	  
	  q0n(anything), `Order`, `-`, `Nr`, `:`, tab, append(order_number(d), `/`, ``), newline
	  	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Datum`, `:`], 300,  invoice_date, date ] )
	  	  	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_line_rule( get_del_note, [
%======================================================================================================

	`Teslimat`, `hesabı`, tab
	
	

	, or([
	
	
	[read_ahead(`YENİ`), dummy(s),  newline, set(delivery_flag)]
	
	,
	
	[delivery_note_number(d), newline,  set(delivery_flag_2)]
	
	])
	

]).


%======================================================================================================
i_rule( get_delivery_details, [
%======================================================================================================

	 q(0,100,line), generic_horizontal_details( [ [`Versandanschrift`, `:` ],50, delivery_hook,s1 ] )
	
	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	
	, get_post_code
	
	, q(0,2,line),  get_delivery_thing( [ shipping_instructions])
	
	, delivery_party(`Bacon Gebäudetechnik  GmbH & Co KG`)
	
]).


%======================================================================================================
i_line_rule( get_delivery_thing( [ Variable ] ), [ nearest( delivery_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================

%======================================================================================================
i_line_rule( get_post_code, [
%======================================================================================================

	delivery_postcode(d), delivery_city(s), newline


]).

%======================================================================================================
i_rule( get_customer_comments, [
%======================================================================================================

	q(0,100,line), generic_horizontal_details( [ [`Baustelle`, `:`],100, customer_comments,s1, newline ] )
	
	
]).


%======================================================================================================
i_rule( get_buyer_reg, [
%======================================================================================================

	q(0,20,line), generic_horizontal_details( [ [read_ahead([ `TR-ADAPTRI`]) ], buyer_registration_number,s1, newline ] )
	
	%, q(0,2,line),  get_buyer_reg_thing( [ buyer_registration_number])
	

]).


%======================================================================================================
i_line_rule( get_buyer_reg_thing( [ Variable ] ), [ nearest( buyer_reg_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [`EMail`, `:`], 200, buyer_email, s, newline ] )
	
	

] ).
%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	or([

		[`Sachbearbeiter`, `:`, tab,  b_contact(s), `DW`, `:`, buyer_ddi(s), newline]
		
		,
		
		[`Sachbearbeiter`, `:`, tab, b_contact(s),  `DW`, `:`,  newline]
		
		])

		, check( i_user_check( reverse_contact, b_contact, Con ) )
		
		, buyer_contact(Con)
		
] ).

%=======================================================================
i_user_check( reverse_contact, Con1, Con )
%=======================================================================
:-
	sys_string_split( Con1, `, `, [ Surname, First_name ] ),
	strcat_list( [ First_name, ` `, Surname ], Con ),
	!
.



%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [`Teslimat`, `Yetkilisi`, `:`], 150, delivery_contact, s ] )
	
] ).

%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [`Teslimat`, `Yeri`, `Telefon`],150, delivery_ddi, s ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%del email and invoice date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	`Teslimat`, `Yeri`, `Eposta`, `:`, tab, delivery_email(w), `@`, append(delivery_email(w), `@`, ``), `.`, append(delivery_email(w), `.`, ``), tab, `Tarih`, `:`, tab, invoice_date(date), newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Netto`, `-`, `Summe` ], 250, total_net, d ] )

		%, q(0, 4, line), generic_horizontal_details( [ [`Toplam` ], 150, total_invoice, d ] )
	
	
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
i_line_rule_cut( line_header_line, [ `Liefer`, `-`, `Termin`, tab, `Preis`, tab, `+`, `/`, `-`, `%`, tab, `Preis`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([
	
		[`Bacon`, `Gebäudetechnik`, `GmbH`, `&`, `CO`, `KG`, `,`, `Sitz`, `:`, `Scherbangasse`, `20`, `,`, `1230`, `Wien`, `,`, `FN`, `187077p`, `HG`, `Wien`, `,`, `UID`, `ATU47601402`, `,`,  newline]
		,
		[ `Netto`, `-`, `Summe`, tab, dummy(d), newline]
		])
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

		
		line_quantity(d)
		
		, trace([`Quantity`, line_quantity])
	
		, line_quantity_uom_code_x(w), tab
		
		, check( line_quantity_uom_code_x = Uom_X )	
		, check( extract_pattern( Uom_X , UOM, [ alpha, alpha, alpha, alpha ] ) )
		, line_quantity_uom_code(UOM)
		
		, check( line_quantity_uom_code_x = Uom_X )	
		, check( extract_pattern( Uom_X , UOM_Y, [ dec, dec, dec, dec, dec, dec ] ) )
		, line_item(UOM_Y) 
		
		, line_descr(s)
		
		, tab
		
		, trace([`line descr`, line_descr])
		
		, line_unit_amount(d)
		
		, tab
		
		, net_amount(d)
		
		, newline
		

		
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).