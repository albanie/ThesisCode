#ifndef MATLAB_H_
#define MATLAB_H_

/*============================================================================*/
/* Includes                                                                   */
/*============================================================================*/
#include <mex.h>
#include <stddef.h> /* for size_t */
#include "macros.h" /* for UNUSED, EMPTY_STATEMENT */
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Utility macros                                                             */
/*============================================================================*/
#define IS_REAL_2D_DOUBLE(P) \
    (!mxIsComplex(P) && mxGetNumberOfDimensions(P) == 2 && mxIsDouble(P))
#define IS_REAL_2D_FULL_DOUBLE(P) \
    (IS_REAL_2D_DOUBLE(P) && !mxIsSparse(P))

#define IS_REAL_SCALAR(P) \
    (IS_REAL_2D_FULL_DOUBLE(P) && mxGetNumberOfElements(P) == 1)

#define IS_REAL_2D_INTEGER(P) \
    (!mxIsComplex(P) && mxGetNumberOfDimensions(P) == 2 && !mxIsDouble(P))

#define IS_REAL_2D_FULL_INTEGER(P) \
    (IS_REAL_2D_INTEGER(P) && !mxIsSparse(P))

#define IS_REAL_INTEGER(P) \
    (IS_REAL_2D_FULL_INTEGER(P) && mxGetNumberOfElements(P) == 1)
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Variable naming                                                            */
/*============================================================================*/
#define ROWS(array)         array##_rows
#define COLS(array)         array##_cols
#define ELEMENTS(vector)    vector##_elements
#define ARRAY(array)        array##_array
#define VECTOR(vector)      vector##_vector
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Types                                                                      */
/*============================================================================*/
typedef double m_double_t;
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Macros for arrays                                                          */
/*============================================================================*/
/* Retrieve a matrix of doubles from a specified location. */
#define RETRIEVE_REAL_DOUBLE_ARRAY(_array_, _location_) \
    const size_t UNUSED ROWS(_array_) = mxGetM(_location_); \
    const size_t UNUSED COLS(_array_) = mxGetN(_location_); \
    mxArray * const UNUSED ARRAY(_array_) = (mxArray *) _location_; \
    m_double_t * const _array_ = mxGetData(ARRAY(_array_)); \
    EMPTY_STATEMENT()

/* Free the memory associated with an array. */
#define FREE_ARRAY(_array_) \
    mxDestroyArray(ARRAY(_array_)); \
    EMPTY_STATEMENT()
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Array properties                                                           */
/*============================================================================*/
/* To access an array element. Uses one-based row/column indexing. */
#define ARRAY_ELEMENT(_array_, _row_, _column_) \
    _array_[(_row_) + ROWS(_array_) * (_column_)]

/* To declare an array and the dimensions of the array in a function signature. */
#define ARRAY_SIGNATURE(_array_) \
    _array_, const size_t UNUSED ROWS(_array_), const size_t UNUSED COLS(_array_)

/* To call a function that requires an array as well as the array dimensions. */
#define ARRAY_ARGUMENTS(_array_) \
    _array_, ROWS(_array_), COLS(_array_)
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Macros for vectors                                                         */
/*============================================================================*/
/* Create a vector of doubles. */
#define CREATE_REAL_DOUBLE_VECTOR(_vector_, _elements_) \
    const size_t ELEMENTS(_vector_) = _elements_; \
    mxArray * const UNUSED VECTOR(_vector_) = mxCreateDoubleMatrix(1, ELEMENTS(_vector_), mxREAL); \
    m_double_t * const _vector_ = mxGetData(VECTOR(_vector_)); \
    EMPTY_STATEMENT()

/* Free the memory associated with a vector. */
#define FREE_VECTOR(_vector_) \
    mxDestroyArray(VECTOR(_vector)); \
    EMPTY_STATEMENT()
/*----------------------------------------------------------------------------*/

/*============================================================================*/
/* Vector properties                                                          */
/*============================================================================*/
/* To access a vector element. Uses one-based element indexing. */
#define VECTOR_ELEMENT(_vector_, _element_) \
    _vector_[(_element_)]

/* To declare a vector and the dimensions of the vector in a function signature. */
#define VECTOR_SIGNATURE(_vector_) \
    _vector_, const size_t UNUSED ELEMENTS(_vector_)

/* To call a function that requires a vector as well as the vector dimensions. */
#define VECTOR_ARGUMENTS(_vector_) \
    _vector_, ELEMENTS(_vector_)
/*----------------------------------------------------------------------------*/

#endif /* #ifndef MATLAB_H_ */