
void main()
{
    int arry[5]= {7,10,0,-5,20};
    int i,j,temp;
    for(i=0;i<4;i++)
    {
        for(j=0;j<4-i;j++)
        {
            if(arry[j]>arry[j+1])
            {
                temp=arry[j];
                arry[j]=arry[j+1];
                arry[j+1]=temp;
            }
        }
    }
}