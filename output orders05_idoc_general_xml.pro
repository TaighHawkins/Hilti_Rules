
i_version( orders05_idoc_general_xml_output, `09 February 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_partner
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_partner___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edka1_partner___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `AG` ),
		
		write_variable_as_tag( invoice, suppliers_code_for_buyer, `PARTN` ),
		
		write_variable_as_tag( invoice, buyers_code_for_buyer, `LIFNR` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_bill_to
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_bill_to___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edka1_bill_to___
%-------------------------------------------------------------------------------
:-	not( q_available_value( invoice, suppliers_code_for_bill_to, `PARTN`, false, _ ) )
	, not( q_available_value( invoice, buyers_code_for_bill_to, `LIFNR`, false, _ ) ).
%===============================================================================

%===============================================================================
write_e1edka1_bill_to___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `RE` ),
		
		write_variable_as_tag( invoice, suppliers_code_for_bill_to, `PARTN` ),
		
		write_variable_as_tag( invoice, buyers_code_for_bill_to, `LIFNR` ),
		
	write_end_element
.

%===============================================================================
write_e1edka1_partner___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `AG` ),
		
		write_variable_as_tag( invoice, suppliers_code_for_buyer, `PARTN` ),
		
		write_variable_as_tag( invoice, buyers_code_for_buyer, `LIFNR` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_supplier
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_supplier___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edka1_supplier___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `LF` ),
		
		write_variable_as_tag( invoice, buyers_code_for_supplier, `PARTN` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_delivery
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_delivery___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%===============================================================================
write_e1edka1_delivery___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `WE` ),
		
		write_variable_as_tag( invoice, delivery_note_number, `PARTN` ),
		
		write_variable_as_tag( invoice, delivery_note_reference, `LIFNR` ),
		
		write_variable_as_tag( invoice, delivery_party, `NAME1` ),
		
		write_variable_as_tag( invoice, delivery_dept, `NAME2` ),
		
		write_variable_as_multi_tag( invoice, delivery_address_line, [ `NAME3`, `NAME4` ] ),
		
		write_variable_as_multi_tag( invoice, delivery_street, [ `STRAS`, `STRS2` ] ),
		
		write_variable_as_tag( invoice, delivery_city, `ORT01` ),
		
		write_variable_as_tag( invoice, delivery_district, `ORT02` ),
		
		write_variable_as_tag( invoice, delivery_postcode, `PSTLZ` ),
		
		write_variable_as_tag( invoice, delivery_country_code, `LAND1` ),
		
		write_variable_as_tag( invoice, delivery_state, `REGIO` ),
		
		write_variable_as_tag( invoice, delivery_location, `ABLAD` ),
		
	write_end_element
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edka1_segments
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edka1_segments___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%===============================================================================
write_custom_e1edka1_segments___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( custom_e1edka1_segment( Parvw, _, Var ),
		trace( trying_custom( Parvw, Var ) ),
		( q_sys_is_string( Var )
			;	result( _, invoice, Var, _ )
		),
		not( i_user_data( used_e1edka1_values, Parvw ) ),
		
		write_custom_e1edka1_segment( Parvw ),
		
		fail
		
		;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edka1_segment( Parvw )
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edka1_segment___( Parvw ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%===============================================================================
write_custom_e1edka1_segment___( Parvw )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	sys_assertz( i_user_data( used_e1edka1_values, Parvw ) ),
	write_start_segment_1_element( `E1EDKA1` ),
	write_element_string( `PARVW`, Parvw ),
	
	( 
		custom_e1edka1_segment( Parvw, Segment, Var ),
		( q_sys_is_string( Var )
			;	result( _, invoice, Var, _ )
		),
		write_custom_e1edka1_segment_component( Segment, Var ),
		
		fail
		
		;	write_end_element
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edka1_segment_component( Segment, Var )
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edka1_segment_component___( Segment, Var ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_custom_e1edka1_segment_component___( Segment, Var )
%-------------------------------------------------------------------------------
:- q_sys_is_string( Var ), write_element_string( Segment, Var ).
%===============================================================================
%===============================================================================
write_custom_e1edka1_segment_component___( Segment, Var )
%-------------------------------------------------------------------------------
:- write_variable_as_tag( invoice, Var, Segment ).
%===============================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_buyer_contact
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_buyer_contact___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edka1_buyer_contact___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `AP` ),
		
		write_variable_as_tag( invoice, buyer_location, `PARTN` ),
		
		write_variable_as_tag( invoice, buyer_dept, `LIFNR` ),
		
		write_first_and_last_name( buyer_contact ),
		
		write_variable_as_tag( invoice, buyer_ddi, `TELF1` ),
		
		write_variable_as_tag( invoice, buyer_fax, `TELFX` ),
		
		( q_available_value( invoice, buyer_email, `SMTP_ADDR`, false, _ )
		
			->	write_start_segment_1_element( `Z1EDKA1` ),
				write_element_string( `PARVW`, `AP` ),
				write_variable_as_tag( invoice, buyer_email, `SMTP_ADDR` ),
				write_end_element
				
			;	true
			
		),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edka1_delivery_contact
%-------------------------------------------------------------------------------
:- d1( write_e1edka1_delivery_contact___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edka1_delivery_contact___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	not( result( _, invoice, delivery_from_contact, _ ) ),
	
	not( result( _, invoice, delivery_from_location, _ ) ),
	
	not( result( _, invoice, delivery_contact, _ ) ),
	
	not( result( _, invoice, delivery_ddi, _ ) ),
	
	not( result( _, invoice, delivery_fax, _ ) ),
	
	not( result( _, invoice, delivery_email, _ ) )	
.

%===============================================================================
write_e1edka1_delivery_contact___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKA1` ),
	
		write_element_string( `PARVW`, `ZV` ),
		
		write_variable_as_tag( invoice, delivery_from_location, `PARTN` ),
		
		write_variable_as_tag( invoice, delivery_from_contact, `LIFNR` ),
		
		write_first_and_last_name( delivery_contact ),
		
		write_variable_as_tag( invoice, delivery_ddi, `TELF1` ),
		
		write_variable_as_tag( invoice, delivery_fax, `TELFX` ),
		
		( q_available_value( invoice, delivery_email, `SMTP_ADDR`, false, _ )
		
			->	write_start_segment_1_element( `Z1EDKA1` ),
				write_element_string( `PARVW`, `ZV` ),
				write_variable_as_tag( invoice, delivery_email, `SMTP_ADDR` ),
				write_end_element
				
			;	true
			
		),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_first_and_last_name( CONTACT )
%-------------------------------------------------------------------------------
:- d1( write_first_and_last_name___( CONTACT ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_first_and_last_name___( CONTACT )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( q_first_and_last_name( CONTACT, NAME1, NAME2 )
	
		->	write_element_string( `NAME1`, NAME1 ),
			write_element_string( `NAME2`, NAME2 )
			
		;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
q_first_and_last_name( CONTACT, NAME1, NAME2 )
%-------------------------------------------------------------------------------
:- q1( q_first_and_last_name___( CONTACT, NAME1, NAME2 ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
q_first_and_last_name___( CONTACT, NAME1, NAME2 )
%-------------------------------------------------------------------------------
:- qq_op_param( orders05_idocs_first_and_last_name( CONTACT, NAME1, NAME2 ), _ ).
%===============================================================================

%===============================================================================
q_first_and_last_name___( CONTACT, NAME1, NAME2 )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	result( _, invoice, CONTACT, VALUE ),
	
	(	q_sys_sub_string( VALUE, _, _, ` ` ),
	
		sys_string_split( VALUE, ` `, TOKENS ),
		
		sys_reverse( TOKENS, [ LAST_NAME | OTHER_NAMES ] ),
			
		sys_reverse( OTHER_NAMES, FIRST_NAMES ),
			
		wordcat( FIRST_NAMES, FIRST_NAME )
			
		;	FIRST_NAME = VALUE,
			LAST_NAME = ``
	),

	% This odd kludge reflects our particular idocs needs for now

	( ( result( _, invoice, agent_code_3, `4400` ) -> true ; result( _, invoice, agent_code_3, `6000` ) ) 
	
		->	string_to_upper( FIRST_NAME, U_FIRST_NAME ),
			
			string_to_upper( LAST_NAME, U_LAST_NAME ),
			
			NAME1 = U_FIRST_NAME,
	
			NAME2 = U_LAST_NAME
					
		;	NAME1 = FIRST_NAME,
	
			NAME2 = LAST_NAME
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_start_segment_1_element( Tag_name )
%-------------------------------------------------------------------------------
:- d1( write_start_segment_1_element___( Tag_name ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_start_segment_1_element___( Tag_name )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( Tag_name ),
	
		write_attribute_string( `SEGMENT`, `1` )
.
