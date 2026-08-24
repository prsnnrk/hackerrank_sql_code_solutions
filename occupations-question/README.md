README:
	In this solution, I have created a stored procedure, called copy_cursor_data, because this procedure processes data from cursors defined inside of it. The first thing I do inside the procedure is I declare and create a few cursors, namely, c_names, c_doctor_names, c_professor_names, c_singer_names, and c_actor_names. What each cursor stores or selects from is as listed below:
	- c_names returns a list of names and occupations, in the order of 'Doctor', 'Professor', 'Singer' and 'Actor'.
	- c_doctor_names returns a list of names and occupations of all Doctors, ordered alphabetically by name.
	- c_professor_names returns a list of names and occupations of all Professors, ordered alphabetically by name.
	- c_singer_names returns a list of names and occupations of all Singers, ordered alphabetically by name.
	- c_actor_names returns a list of names and occupations of all Actors, ordered alphabetically by name.
	
Then, I have declared some variables to be used as width spacing for the RPAD function which is used to format the output into 4 columns based on the 4 different occupations as required by the question. I then declare a string array type, and initialize 4 of these string arrays to hold values for each column. After that, I define some tables to store values from the cursors. I open each cursor and transfer all data to their corresponding tables, in bulk, using FETCH...BULK COLLECT INTO. In order to populate the output with the correct number of null values, I find the length of the longest column using GROUP BY occupation, alongside the COUNT aggregate function, and then filter out the highest value. I then proceed to create a FOR LOOP with its range from 1 to this highest value, with IF ELSE statements to append people's names to their specific occupation string array, or else append 'NULL' when there are no more names falling under that category of occupation. Finally, I display the result from the string arrays using the RPAD function which right-pads the name values with spaces for each following column, and then, call the procedure.

The sample output is as such:

Aamina Ashley Christeen Eve
Julia Belvet Jane Jennifer
Priya Britney Jenny Ketty
NULL Maria Kristeen Samantha
NULL Meera NULL NULL
NULL Naomi NULL NULL
NULL Priyanka NULL NULL
